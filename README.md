# Rogue-Recreation-Mobile

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
- [ ] **MeleeAttackComponent / WeaponComponent** — Player swings/hitboxes
- [ ] **ProjectileShooterComponent & ProjectileComponent** — Wands, bows, darts
- [ ] **DashComponent** — Mobile dodge roll with i-frames

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
