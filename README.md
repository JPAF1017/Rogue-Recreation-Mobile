# Rogue-Recreation-Mobile

Current Plan & Component Registry:

├── Movement & Locomotion
│   └── MovementComponent (Velocity, acceleration, friction)    DONE
│
├── Combat & Action
│   ├── DamageDealerComponent (Hitbox & payload dispatch)   DONE
│   ├── DamageReceiverComponent (Hurtbox & mitigation coordinator)  DONE
│   ├── ArmorComponent (Damage reduction & rust mechanics)  DONE
│   ├── InvulnerabilityComponent (Multi-source i-frames tracking)   DONE
│   ├── KnockbackComponent (Impulse application on hit) DONE
│   ├── HitFlashComponent (Sprite hit color/flash feedback) DONE
│   ├── MeleeAttackComponent / WeaponComponent (Player swings/hitboxes)
│   ├── ProjectileShooterComponent & ProjectileComponent (Wands, bows, darts)
│   └── DashComponent (Mobile dodge roll with i-frames)
│
├── Core Rogue Systems
│   ├── HealthComponent (HP, death, heal signals)   DONE
│   ├── StatsComponent (XP, Level, Strength, Gold)
│   ├── HungerComponent (Real-time starvation clock)
│   ├── StatusEffectComponent (Poison, Confusion, Haste, Blindness, Sleep)
│   ├── InventoryComponent & EquipmentComponent (Gear, potions, scrolls)
│   └── IdentificationComponent (Unidentified items per run)
│
├── Sensors & Aiming
│   ├── TargetDetectorComponent (Proximity target detection)    DONE
│   └── AutoAimComponent (Mobile touch-screen aim assist)   DONE
│
├── Visuals & Presentation (Asset Manipulation / UI)
│   ├── FlipperComponent (Sprite flipping based on move direction)  DONE
│   ├── RotatorComponent (Visual rotation toward target)    DONE
│   └── HealthBarComponent (Floating/anchored HP gauge) DONE
│
├── Enemy AI & Behaviors
│   ├── EnemyAIComponent / BehaviorTree / StateMachine (Idle, Chase, Flee)
│   ├── NavigationComponent (Godot pathfinding through dungeon corridors)
│   └── MonsterTraitComponent (Rust armor, steal items, drain XP/stats)
│
└── World & Interactions
    ├── InteractorComponent & InteractableComponent (Chests, stairs, doors)
    ├── LootDropComponent & PickupComponent (Floor items, gold drops)
    ├── TrapComponent (Bear trap, dart, teleport, rust, sleeping gas)
    └── DungeonTransitionComponent (Stairs down / up with Amulet)
