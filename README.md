# Rogue-Recreation-Mobile

A real-time 2D mobile reimagining of the classic dungeon crawler Rogue (1980), built in Godot 4.

This project transforms the original turn-based, grid-based ASCII experience into a fast-paced, action-oriented roguelike tailored for mobile touch controls, while preserving iconic Rogue mechanics like the hunger clock, unidentified scrolls/potions, dungeon traps, and procedural peril. The architecture follows a strictly decoupled, modular Entity-Component pattern for seamless assembly.

---

## Component Roadmap & Registry

### 🏃 Movement & Locomotion
- [x] **MovementComponent** — Velocity, acceleration, friction

### ⚔️ Combat & Action
- [x] **DamageDealerComponent** — Hitbox & payload dispatch
- [x] **DamageReceiverComponent** — Hurtbox & mitigation coordinator
- [x] **ArmorComponent** — Damage reduction & rust mechanics
- [x] **InvulnerabilityComponent** — Multi-source i-frames tracking
- [x] **KnockbackComponent** — Impulse application on hit
- [x] **HitFlashComponent** — Sprite hit color/flash feedback
- [x] **MeleeAttackComponent / WeaponComponent** — Player swings/hitboxes
- [x] **ProjectileShooterComponent & ProjectileComponent** — Wands, bows, darts
- [x] **DashComponent** — Mobile dodge roll with i-frames

### 📜 Core Rogue Systems
- [x] **HealthComponent** — HP, death, heal signals
- [ ] **StatsComponent** — XP, Level, Strength, Gold
- [ ] **HungerComponent** — Real-time starvation clock
- [ ] **StatusEffectComponent** — Poison, Confusion, Haste, Blindness, Sleep
- [ ] **InventoryComponent & EquipmentComponent** — Gear, potions, scrolls
- [ ] **IdentificationComponent** — Unidentified items per run

### 🎯 Sensors & Aiming
- [x] **TargetDetectorComponent** — Proximity target detection
- [x] **AutoAimComponent** — Mobile touch-screen aim assist

### 🎨 Visuals & Presentation
- [x] **FlipperComponent** — Sprite flipping based on move direction
- [x] **RotatorComponent** — Visual rotation toward target
- [x] **HealthBarComponent** — Floating/anchored HP gauge

### 👾 Enemy AI & Behaviors
- [ ] **EnemyAIComponent / StateMachine** — Idle, Chase, Flee
- [ ] **NavigationComponent** — Godot pathfinding through dungeon corridors
- [ ] **MonsterTraitComponent** — Rust armor, steal items, drain XP/stats

### 🗝️ World & Interactions
- [ ] **InteractorComponent & InteractableComponent** — Chests, stairs, doors
- [ ] **LootDropComponent & PickupComponent** — Floor items, gold drops
- [ ] **TrapComponent** — Bear trap, dart, teleport, rust, sleeping gas
- [ ] **DungeonTransitionComponent** — Stairs down / up with Amulet
