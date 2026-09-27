//! A* Pathfinding for 8x8 Grid (expandable)
//!
//! Supports: walkable tiles, terrain MOV cost, flyable units

use std::collections::HashMap;

use petgraph::{
    algo::astar,
    graph::{Graph, NodeIndex},
    visit::EdgeRef,
};

use crate::error::PathfindingError;

#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash, serde::Serialize, serde::Deserialize)]
pub struct GridPos {
    pub x: i32,
    pub y: i32,
}

impl GridPos {
    pub fn new(x: i32, y: i32) -> Self {
        Self { x, y }
    }
    pub fn distance(&self, other: &GridPos) -> i32 {
        (self.x - other.x).abs() + (self.y - other.y).abs()
    }
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum MoveType {
    Walk,
    Fly,
}

#[derive(Debug, Clone)]
pub struct Grid {
    pub width: i32,
    pub height: i32,
    pub walkable: Vec<Vec<bool>>,
    pub mov_cost: Vec<Vec<i32>>, // Additional MOV cost per tile
    pub flyable: Vec<Vec<bool>>,
    graph: Graph<GridPos, i32>,
    node_map: HashMap<(i32, i32), NodeIndex>,
}

impl Grid {
    pub fn new(width: i32, height: i32) -> Result<Self, PathfindingError> {
        if width <= 0 || height <= 0 {
            return Err(PathfindingError::InvalidGrid { width, height });
        }

        let mut graph = Graph::new();
        let mut node_map = HashMap::new();
        let walkable = vec![vec![true; width as usize]; height as usize];
        let mov_cost = vec![vec![0; width as usize]; height as usize];
        let flyable = vec![vec![true; width as usize]; height as usize];

        for y in 0..height {
            for x in 0..width {
                let node = graph.add_node(GridPos::new(x, y));
                node_map.insert((x, y), node);
            }
        }

        // Add edges (4-directional)
        for y in 0..height {
            for x in 0..width {
                let node = node_map[&(x, y)];
                for (dx, dy) in [(0, 1), (1, 0), (0, -1), (-1, 0)] {
                    let nx = x + dx;
                    let ny = y + dy;
                    if nx >= 0 && nx < width && ny >= 0 && ny < height {
                        let neighbor = node_map[&(nx, ny)];
                        // Cost will be determined by target tile
                        graph.add_edge(node, neighbor, 1);
                    }
                }
            }
        }

        Ok(Self { width, height, walkable, mov_cost, flyable, graph, node_map })
    }

    pub fn set_tile(&mut self, x: i32, y: i32, walkable: bool, mov_cost: i32, flyable: bool) {
        if x >= 0 && x < self.width && y >= 0 && y < self.height {
            self.walkable[y as usize][x as usize] = walkable;
            self.mov_cost[y as usize][x as usize] = mov_cost;
            self.flyable[y as usize][x as usize] = flyable;
        }
    }

    /// Find path from start to goal within MOV range
    /// Returns (path, total_cost) or None if no path / out of range
    pub fn find_path(
        &self,
        start: GridPos,
        goal: GridPos,
        max_mov: i32,
        move_type: MoveType,
    ) -> Option<(Vec<GridPos>, i32)> {
        if !self.in_bounds(start) || !self.in_bounds(goal) {
            return None;
        }

        let start_node = self.node_map.get(&(start.x, start.y))?;
        let goal_node = self.node_map.get(&(goal.x, goal.y))?;

        // Check if goal is passable
        if move_type == MoveType::Walk {
            if !self.walkable[goal.y as usize][goal.x as usize] {
                return None;
            }
        } else {
            if !self.flyable[goal.y as usize][goal.x as usize] {
                return None;
            }
        }

        // Custom edge cost function
        let edge_cost = |edge: petgraph::graph::EdgeReference<i32>| {
            let target = edge.target();
            let pos = self.graph[target];
            let tile_cost = 1 + self.mov_cost[pos.y as usize][pos.x as usize];
            if move_type == MoveType::Walk && !self.walkable[pos.y as usize][pos.x as usize] {
                i32::MAX
            } else if move_type == MoveType::Fly && !self.flyable[pos.y as usize][pos.x as usize] {
                i32::MAX
            } else {
                tile_cost
            }
        };

        let heuristic = |node: NodeIndex| {
            let pos = self.graph[node];
            pos.distance(&goal)
        };

        let result = astar(&self.graph, *start_node, |n| n == *goal_node, edge_cost, heuristic);

        result
            .map(|(cost, path_nodes)| {
                let path: Vec<GridPos> = path_nodes.iter().map(|n| self.graph[*n]).collect();
                (path, cost)
            })
            .and_then(|(path, cost)| if cost <= max_mov { Some((path, cost)) } else { None })
    }

    /// Get all reachable positions within MOV range
    pub fn get_reachable(
        &self,
        start: GridPos,
        max_mov: i32,
        move_type: MoveType,
    ) -> Vec<(GridPos, i32)> {
        let mut reachable = Vec::new();

        if !self.in_bounds(start) {
            return reachable;
        }

        let start_node = self.node_map[&(start.x, start.y)];
        let mut costs = HashMap::new();
        costs.insert(start_node, 0);

        // Dijkstra-like for all reachable
        let mut frontier = vec![start_node];

        while let Some(current) = frontier.pop() {
            let current_cost = costs[&current];
            if current_cost >= max_mov {
                continue;
            }

            for edge in self.graph.edges(current) {
                let next = edge.target();
                let pos = self.graph[next];

                let passable = match move_type {
                    MoveType::Walk => self.walkable[pos.y as usize][pos.x as usize],
                    MoveType::Fly => self.flyable[pos.y as usize][pos.x as usize],
                };
                if !passable {
                    continue;
                }

                let tile_cost = 1 + self.mov_cost[pos.y as usize][pos.x as usize];
                let new_cost = current_cost + tile_cost;

                if new_cost > max_mov {
                    continue;
                }

                if !costs.contains_key(&next) || new_cost < costs[&next] {
                    costs.insert(next, new_cost);
                    frontier.push(next);
                }
            }
        }

        for (node, cost) in costs {
            if cost > 0 {
                // Exclude start position
                let pos = self.graph[node];
                reachable.push((pos, cost));
            }
        }

        reachable
    }

    fn in_bounds(&self, pos: GridPos) -> bool {
        pos.x >= 0 && pos.x < self.width && pos.y >= 0 && pos.y < self.height
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_basic_pathfinding() {
        let grid = Grid::new(8, 8).unwrap();
        let start = GridPos::new(0, 0);
        let goal = GridPos::new(3, 3);

        let result = grid.find_path(start, goal, 10, MoveType::Walk);
        assert!(result.is_some());
        let (path, cost) = result.unwrap();
        assert_eq!(path[0], start);
        assert_eq!(path[path.len() - 1], goal);
        assert_eq!(cost, 6); // Manhattan distance
    }

    #[test]
    fn test_blocked_tile() {
        let mut grid = Grid::new(5, 5).unwrap();
        grid.set_tile(1, 0, false, 0, false); // Block (1,0)

        let start = GridPos::new(0, 0);
        let goal = GridPos::new(2, 0);

        // Direct path blocked
        let result = grid.find_path(start, goal, 10, MoveType::Walk);
        assert!(result.is_none());

        // But can go around
        let goal2 = GridPos::new(2, 1);
        let result2 = grid.find_path(start, goal2, 10, MoveType::Walk);
        assert!(result2.is_some());
    }

    #[test]
    fn test_fly_over_mountain() {
        let mut grid = Grid::new(5, 5).unwrap();
        grid.set_tile(1, 0, false, 0, true); // Mountain: not walkable, but flyable

        let start = GridPos::new(0, 0);
        let goal = GridPos::new(2, 0);

        // Walking unit cannot pass
        let result = grid.find_path(start, goal, 10, MoveType::Walk);
        assert!(result.is_none());

        // Flying unit can pass
        let result = grid.find_path(start, goal, 10, MoveType::Fly);
        assert!(result.is_some());
    }

    #[test]
    fn test_reachable_positions() {
        let grid = Grid::new(8, 8).unwrap();
        let start = GridPos::new(4, 4);
        let reachable = grid.get_reachable(start, 5, MoveType::Walk);

        // Should have positions within MOV 5
        assert!(!reachable.is_empty());
        for (pos, cost) in reachable {
            assert!(cost <= 5);
            assert!(pos.distance(&start) <= 5);
        }
    }
}
