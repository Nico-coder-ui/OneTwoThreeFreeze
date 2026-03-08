# Système de mort — Comment ça marche

## Vue d'ensemble

Quand une voiture touche le poulet (joueur), voici ce qui se passe :
1. La voiture **détecte la collision** et appelle `die()` sur le joueur
2. Le joueur est **propulsé** dans la direction de la voiture (knockback)
3. Une **animation de mort** se joue (flash rouge → tombe → disparaît)
4. Le jeu **se ferme** (tu pourras remplacer par un menu plus tard)

---

## Fichiers modifiés et pourquoi

### 1. `red_car.tscn` — La scène de la voiture

```
contact_monitor = true
max_contacts_reported = 4
```

**Pourquoi ?** Un `RigidBody3D` dans Godot ne déclenche **aucun signal** (`body_entered`, `body_exited`, etc.) sauf si `contact_monitor = true`. Sans ça, le signal `body_entered` ne se connecte même pas correctement. `max_contacts_reported = 4` dit au moteur de suivre jusqu'à 4 contacts simultanés (suffisant pour notre cas).

> **Règle Godot** : Pas de `contact_monitor` = pas de signal de collision sur un RigidBody3D. C'est désactivé par défaut pour des raisons de performance.

---

### 2. `red_car_forward.gd` — Le script de la voiture

```gdscript
func _on_body_entered(body):
    if body.is_in_group("player") and body.has_method("die"):
        var knockback_dir = global_transform.basis.z.normalized()
        body.die(knockback_dir)
```

**Ligne par ligne :**
- `body_entered` est un signal émis quand le RigidBody3D touche un autre corps physique
- `body.is_in_group("player")` → vérifie que c'est bien le joueur et pas un mur ou autre
- `body.has_method("die")` → sécurité pour éviter un crash si l'objet n'a pas la méthode
- `global_transform.basis.z` → c'est l'axe "avant" de la voiture en coordonnées mondiales. On l'utilise comme direction du knockback pour que le joueur soit poussé dans le sens où la voiture roulait
- `body.die(knockback_dir)` → appelle la fonction de mort sur le joueur

---

### 3. `player.gd` — Le script du joueur (le gros morceau)

#### Variables ajoutées

```gdscript
const KNOCKBACK_FORCE = 15.0  # Puissance de la propulsion
var is_dead := false           # Est-ce que le joueur est mort ?
var knockback_velocity := Vector3.ZERO  # Vélocité de recul
```

- `is_dead` empêche le joueur de mourir 2 fois (si 2 voitures le touchent en même temps)
- `knockback_velocity` est séparé de `velocity` pour pouvoir le freiner progressivement

#### La fonction `die()`

```gdscript
func die(knockback_dir: Vector3) -> void:
    if is_dead:
        return  # Empêche de mourir 2 fois

    is_dead = true

    # 1) Propulsion
    knockback_velocity = knockback_dir * KNOCKBACK_FORCE + Vector3.UP * 5.0

    # 2) Animation avec un Tween
    var mesh = $MeshInstance3D
    var tween = create_tween()

    # A) Flash rouge
    var red_material = StandardMaterial3D.new()
    red_material.albedo_color = Color(1, 0.2, 0.2, 1)
    red_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
    mesh.material_override = red_material

    # B) Rotation 90° (tombe sur le dos)
    tween.tween_property(self, "rotation_degrees:x", -90.0, 0.4)

    # C) Petite pause
    tween.tween_interval(0.3)

    # D) Fondu (alpha de 1 → 0)
    tween.tween_property(red_material, "albedo_color:a", 0.0, 0.5)

    # E) Destruction + quitter
    tween.tween_callback(_on_death_finished)
```

**Comment le Tween fonctionne :**

Un `Tween` est un outil d'animation par code dans Godot. Chaque `tween_property` / `tween_interval` / `tween_callback` s'exécute **à la suite** (séquentiellement). La timeline est :

```
t=0.0s  → Flash rouge immédiat + début rotation
t=0.4s  → Rotation terminée (90°), début pause
t=0.7s  → Fin pause, début fondu
t=1.2s  → Fondu terminé, appel _on_death_finished()
```

- `tween_property(objet, "propriété", valeur_finale, durée)` → anime une propriété
- `tween_interval(durée)` → attend X secondes
- `tween_callback(fonction)` → appelle une fonction
- `set_ease(Tween.EASE_OUT)` → la rotation ralentit vers la fin (plus naturel)

#### Le _physics_process modifié

```gdscript
func _physics_process(delta):
    if is_dead:
        # Applique knockback + gravité, PAS d'input joueur
        knockback_velocity += get_gravity() * delta
        knockback_velocity.x = move_toward(knockback_velocity.x, 0, 5.0 * delta)
        knockback_velocity.z = move_toward(knockback_velocity.z, 0, 5.0 * delta)
        velocity = knockback_velocity
        move_and_slide()
        return  # ← IMPORTANT : le return empêche le code d'input de s'exécuter
    
    # ... code normal de déplacement ...
```

**Pourquoi un `return` ?** Quand le joueur est mort, on ne veut plus qu'il puisse se déplacer. Le `return` coupe l'exécution avant le code d'input. Le knockback est freiné progressivement avec `move_toward` pour un effet naturel.

---

## Résumé du flux complet

```
Voiture roule → touche le joueur
    ↓
RigidBody3D émet body_entered (grâce à contact_monitor = true)
    ↓
red_car_forward.gd::_on_body_entered() est appelé
    ↓
Vérifie que c'est le joueur (group "player")
    ↓
Calcule la direction du knockback (axe Z global de la voiture)
    ↓
Appelle player.die(knockback_dir)
    ↓
player.gd::die() :
  - is_dead = true (bloque les inputs)
  - Applique knockback_velocity (propulsion)
  - Crée un Tween :
      0.0s → Flash rouge
      0.0-0.4s → Rotation -90° sur X
      0.4-0.7s → Pause
      0.7-1.2s → Fondu transparent
      1.2s → queue_free() + get_tree().quit()
```

---

## Pour plus tard : remplacer quit() par un menu

Dans `_on_death_finished()`, remplace :
```gdscript
get_tree().quit()
```
par :
```gdscript
get_tree().change_scene_to_file("res://Level/game_over.tscn")
```

---

## Paramètres ajustables

| Variable | Fichier | Effet |
|---|---|---|
| `KNOCKBACK_FORCE` | player.gd | Force de propulsion (défaut: 15) |
| `Vector3.UP * 5.0` | player.gd | Hauteur du saut de mort |
| `0.4` (rotation) | player.gd | Durée de la chute en secondes |
| `0.3` (interval) | player.gd | Pause avant le fondu |
| `0.5` (alpha) | player.gd | Durée du fondu |
| `Color(1, 0.2, 0.2)` | player.gd | Couleur du flash de mort |
