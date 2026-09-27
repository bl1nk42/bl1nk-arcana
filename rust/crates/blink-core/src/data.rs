//! Data definitions and loaders for Blink Arcana
//! Loads from .tres resources or JSON

use std::{collections::HashMap, fs, path::Path};

use serde::{Deserialize, Serialize};

use crate::{
    error::DataError,
    stats::{BaseStats, CombatModifiers, UnitStats},
};

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct UnitData {
    pub id: String,
    pub name: String,
    pub class_line: String,
    pub class: String,
    pub class_tier: u8,
    pub element: String,
    pub level: u8,
    pub base_stats: BaseStats,
    pub growth_rates: BaseStats, // per level
    pub skill_ids: Vec<String>,  // learnable skills
    pub promotion_item: Option<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SkillData {
    pub id: String,
    pub name: String,
    pub skill_type: String, // "Passive", "Active", "Reactive", "Command"
    pub slot_cost: u8,
    pub unlock_cp: u8,
    pub cooldown: u8,
    pub range: u8,
    pub class_line: String,
    pub unlock_tier: u8,
    pub effect: SkillEffectData,
    pub description: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SkillEffectData {
    pub effect_type: String,
    pub params: HashMap<String, String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct WeaponData {
    pub id: String,
    pub name: String,
    pub weapon_type: String,
    pub rank: String,
    pub atk_bonus: i32,
    pub secondary_stat: Option<String>,
    pub secondary_value: i32,
    pub durability: u16,
    pub ability: Option<WeaponAbilityData>,
    pub element: Option<String>,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct WeaponAbilityData {
    pub id: String,
    pub name: String,
    pub skill_type: String,
    pub effect: SkillEffectData,
    pub description: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ArmorData {
    pub id: String,
    pub name: String,
    pub armor_type: String,
    pub def_bonus: i32,
    pub mov_penalty: i32,
    pub res_bonus: i32,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct AccessoryData {
    pub id: String,
    pub name: String,
    pub rarity: u8,
    pub stat_bonuses: HashMap<String, i32>,
    pub passive_effect: Option<String>,
    pub description: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ClassData {
    pub id: String,
    pub name: String,
    pub class_line: String,
    pub tier: u8,
    pub base_stats: BaseStats,
    pub growth_rates: BaseStats,
    pub promotion_item: String,
    pub learnable_skills: Vec<String>,
    pub weapon_types: Vec<String>,
    pub movement_type: String, // "walk", "fly"
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct TerrainData {
    pub id: String,
    pub name: String,
    pub def_bonus: i32,
    pub avo_bonus: i32,
    pub mov_penalty: i32,
    pub heal_per_turn: i32,
    pub special: String,
    pub walkable: bool,
    pub flyable: bool,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct MapData {
    pub id: String,
    pub name: String,
    pub width: u16,
    pub height: u16,
    pub tiles: Vec<Vec<String>>, // terrain IDs
    pub player_spawn: Vec<(u16, u16)>,
    pub enemy_spawn: Vec<(u16, u16)>,
    pub objectives: Vec<(u16, u16, String)>, // x, y, type
}

/// Data Registry - loads and caches all game data
pub struct DataRegistry {
    pub units: HashMap<String, UnitData>,
    pub skills: HashMap<String, SkillData>,
    pub weapons: HashMap<String, WeaponData>,
    pub armors: HashMap<String, ArmorData>,
    pub accessories: HashMap<String, AccessoryData>,
    pub classes: HashMap<String, ClassData>,
    pub terrains: HashMap<String, TerrainData>,
    pub maps: HashMap<String, MapData>,
}

impl Default for DataRegistry {
    fn default() -> Self {
        Self::new()
    }
}

impl DataRegistry {
    pub fn new() -> Self {
        Self {
            units: HashMap::new(),
            skills: HashMap::new(),
            weapons: HashMap::new(),
            armors: HashMap::new(),
            accessories: HashMap::new(),
            classes: HashMap::new(),
            terrains: HashMap::new(),
            maps: HashMap::new(),
        }
    }

    /// Load all data from directory (JSON files)
    pub fn load_from_dir(&mut self, path: &str) -> Result<(), DataError> {
        let base = Path::new(path);

        // Load each type
        self.units = self.load_json_dir(base.join("units"))?;
        self.skills = self.load_json_dir(base.join("skills"))?;
        self.weapons = self.load_json_dir(base.join("weapons"))?;
        self.armors = self.load_json_dir(base.join("armors"))?;
        self.accessories = self.load_json_dir(base.join("accessories"))?;
        self.classes = self.load_json_dir(base.join("classes"))?;
        self.terrains = self.load_json_dir(base.join("terrains"))?;
        self.maps = self.load_json_dir(base.join("maps"))?;

        Ok(())
    }

    fn load_json_dir<T: for<'de> Deserialize<'de>>(
        &self,
        dir: std::path::PathBuf,
    ) -> Result<HashMap<String, T>, DataError> {
        let mut map = HashMap::new();

        if !dir.exists() {
            return Ok(map);
        }

        for entry in fs::read_dir(dir).map_err(|e| DataError::UnitNotFound(e.to_string()))? {
            let entry = entry.map_err(|e| DataError::UnitNotFound(e.to_string()))?;
            let path = entry.path();

            if path.extension().map_or(false, |ext| ext == "json") {
                let content = fs::read_to_string(&path)
                    .map_err(|e| DataError::UnitNotFound(e.to_string()))?;
                let data: T = serde_json::from_str(&content)
                    .map_err(|e| DataError::UnitNotFound(e.to_string()))?;

                // Use filename (without extension) as key
                if let Some(stem) = path.file_stem().and_then(|s| s.to_str()) {
                    map.insert(stem.to_string(), data);
                }
            }
        }

        Ok(map)
    }

    // Getters
    pub fn get_unit(&self, id: &str) -> Result<&UnitData, DataError> {
        self.units.get(id).ok_or_else(|| DataError::UnitNotFound(id.to_string()))
    }

    pub fn get_skill(&self, id: &str) -> Result<&SkillData, DataError> {
        self.skills.get(id).ok_or_else(|| DataError::SkillNotFound(id.to_string()))
    }

    pub fn get_weapon(&self, id: &str) -> Result<&WeaponData, DataError> {
        self.weapons.get(id).ok_or_else(|| DataError::WeaponNotFound(id.to_string()))
    }

    pub fn get_class(&self, id: &str) -> Result<&ClassData, DataError> {
        self.classes.get(id).ok_or_else(|| DataError::InvalidClassLine(id.to_string()))
    }

    pub fn get_terrain(&self, id: &str) -> Result<&TerrainData, DataError> {
        self.terrains.get(id).ok_or_else(|| DataError::UnitNotFound(id.to_string()))
    }

    pub fn get_map(&self, id: &str) -> Result<&MapData, DataError> {
        self.maps.get(id).ok_or_else(|| DataError::UnitNotFound(id.to_string()))
    }

    /// Convert UnitData to runtime UnitStats
    pub fn create_unit_stats(&self, unit_id: &str, level: u8) -> Result<UnitStats, DataError> {
        let data = self.get_unit(unit_id)?;
        let class_data = self.get_class(&data.class)?;

        let mut stats = data.base_stats;

        // Apply growth rates
        for i in 1..level {
            stats.hp += data.growth_rates.hp;
            stats.atk += data.growth_rates.atk;
            stats.def += data.growth_rates.def;
            stats.int += data.growth_rates.int;
            stats.spd += data.growth_rates.spd;
            stats.mov += data.growth_rates.mov;
            stats.rng += data.growth_rates.rng;
            stats.res += data.growth_rates.res;
        }

        Ok(UnitStats::new(stats))
    }
}

#[cfg(test)]
mod tests {
    use std::io::Write;

    use tempfile::tempdir;

    use super::*;

    fn make_test_registry() -> DataRegistry {
        let mut reg = DataRegistry::new();

        // Add test unit
        reg.units.insert(
            "test_unit".to_string(),
            UnitData {
                id: "test_unit".to_string(),
                name: "Test Unit".to_string(),
                class_line: "Sword".to_string(),
                class: "Myrmidon".to_string(),
                class_tier: 1,
                element: "Fire".to_string(),
                level: 1,
                base_stats: BaseStats {
                    hp: 80,
                    atk: 30,
                    def: 15,
                    int: 10,
                    spd: 10,
                    mov: 5,
                    rng: 1,
                    res: 10,
                },
                growth_rates: BaseStats {
                    hp: 3,
                    atk: 2,
                    def: 1,
                    int: 1,
                    spd: 1,
                    mov: 0,
                    rng: 0,
                    res: 1,
                },
                skill_ids: vec!["sword_e".to_string(), "dodge_5".to_string()],
                promotion_item: Some("Junior_Crest".to_string()),
            },
        );

        reg.classes.insert(
            "Myrmidon".to_string(),
            ClassData {
                id: "Myrmidon".to_string(),
                name: "Myrmidon".to_string(),
                class_line: "Sword".to_string(),
                tier: 1,
                base_stats: BaseStats {
                    hp: 80,
                    atk: 30,
                    def: 15,
                    int: 10,
                    spd: 10,
                    mov: 5,
                    rng: 1,
                    res: 10,
                },
                growth_rates: BaseStats {
                    hp: 3,
                    atk: 2,
                    def: 1,
                    int: 1,
                    spd: 1,
                    mov: 0,
                    rng: 0,
                    res: 1,
                },
                promotion_item: "Junior_Crest".to_string(),
                learnable_skills: vec![
                    "sword_e".to_string(),
                    "dodge_5".to_string(),
                    "focus_3".to_string(),
                    "parity_2".to_string(),
                ],
                weapon_types: vec!["Sword".to_string()],
                movement_type: "walk".to_string(),
            },
        );

        reg
    }

    #[test]
    fn test_create_unit_stats() {
        let reg = make_test_registry();
        let stats = reg.create_unit_stats("test_unit", 5).unwrap();

        // Level 1 base + 4 levels growth
        assert_eq!(stats.base.hp, 80 + 3 * 4); // 92
        assert_eq!(stats.base.atk, 30 + 2 * 4); // 38
    }

    #[test]
    fn test_load_from_dir() {
        let dir = tempdir().unwrap();
        let units_dir = dir.path().join("units");
        fs::create_dir_all(&units_dir).unwrap();

        let unit_json = r#"{
            "id": "myrmidon",
            "name": "Myrmidon",
            "class_line": "Sword",
            "class": "Myrmidon",
            "class_tier": 1,
            "element": "Fire",
            "level": 1,
            "base_stats": {"hp": 80, "atk": 30, "def": 15, "int": 10, "spd": 10, "mov": 5, "rng": 1, "res": 10},
            "growth_rates": {"hp": 3, "atk": 2, "def": 1, "int": 1, "spd": 1, "mov": 0, "rng": 0, "res": 1},
            "skill_ids": ["sword_e", "dodge_5"],
            "promotion_item": "Junior_Crest"
        }"#;

        let mut file = fs::File::create(units_dir.join("myrmidon.json")).unwrap();
        file.write_all(unit_json.as_bytes()).unwrap();

        let mut reg = DataRegistry::new();
        reg.load_from_dir(dir.path().to_str().unwrap()).unwrap();

        let unit = reg.get_unit("myrmidon").unwrap();
        assert_eq!(unit.name, "Myrmidon");
        assert_eq!(unit.base_stats.hp, 80);
    }
}
