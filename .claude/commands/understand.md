# /understand — Confirm Understanding

Verify understanding of a feature/spec before implementation.

## Usage

```
/understand <feature_name>
```

## Process

1. Reads spec from docs/SPECS/<feature_name>.md
2. Summarizes key points
3. Asks confirmation questions
4. Records understanding in task notes

## Example Interaction

```
User: /understand "Card Draw System"

AI: === Understanding Check: Card Draw System ===

Key Points from Spec:
1. Deck: 20-30 cards, shuffled at battle start
2. Draw: 5 cards initial, 1 per turn (max hand 6)
3. Play: Drag card to target (Unit Display / Party Slot)
4. Discard: Played cards go to discard pile
5. Reshuffle: When deck empty, shuffle discard → deck

Questions:
1. Should "Hand" UI be called "Party Slots" per GLOSSARY.md?
2. Mulligan rule? (Redraw initial hand once)
3. Card limits per type? (e.g., max 3 copies)

Please confirm or correct.
```

## Confirmation

After user confirms: "Understanding recorded for TASK-XXX"
