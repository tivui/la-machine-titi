# Plan de customisation de La Machine

Ce fichier documente le plan pour
- modifier les sons de La Machine
- associer des mouvements personnalisés
- conserver la possibilité de revenir au code d'origine
- préparer une interface web plus tard

## Contexte actuel

- Branche active : `custom/mes_sons`
- Erlang/OTP : pas encore installé sur la machine
- Flashage du device : pas encore testé
- Premier son personnalisé : un MP3 de l'UEFA Champions League dans `sounds/personal`
- Préférence : on peut commencer par modifier les données JSON et les MP3, puis décider si on apprend Erlang plus tard.

## Objectif Phase 1

1. Ajouter des sons personnalisés dans `sounds/`
2. Ajouter de nouveaux scénarios dans `choreographies.json`
3. Recompiler les assets (scénarios + partition sons)
4. Flasher le device via USB-C
5. Garder toujours une route de retour vers l'original

## Étapes recommandées

### 1. Préparer le dépôt

```bash
cd C:\Users\Asus\Documents\Projets\LAMACHINE\la_machine
git checkout -b custom/mes_sons
```

### 2. Installer les outils nécessaires

- Erlang/OTP 27+ (ou version compatible avec AtomVM)
- `rebar3`
- `esptool` (Python)

Sur Windows, la meilleure approche est souvent via WSL2 ou Git Bash si vous n'avez pas encore Erlang.

### 3. Ajouter un son personnel

Placez votre fichier MP3 dans un dossier dédié comme :

```text
sounds/personal/uefachampions_01.mp3
```

### 4. Ajouter un scénario personnalisé

Un scénario est une suite d'actions dans `choreographies.json`.
Exemple :

```json
{
  "personal_uefa_01": "{servo, 50, 300}, {wait, 100}, {mp3, <<\"personal/uefachampions_01.mp3\">>}, {wait, 2000}, {servo, 0, 200}"
}
```

### 5. Construire les assets

Le script de build génère :
- `la_machine_scenarios.hrl` à partir de `choreographies.json`
- `sounds.bin` à partir du dossier `sounds/`

Le processus passe par `rebar3` et `scripts/build_assets.escript`.

### 6. Flasher le device

**Important** : si tu modifies les sons (ajout, suppression ou modification d'un fichier MP3), l'index des sons est recompilé et intégré dans le code Erlang. Il faut donc toujours flasher **deux partitions** :
- Le code Erlang (`la_machine.avm`) à l'offset `0x130000`
- La partition sons (`sounds.bin`) à l'offset `0x230000`

La solution la plus simple est de flasher l'image complète (produite par la CI GitHub Actions) :

```bash
esptool.py --chip esp32c3 --port COM3 write_flash 0 la_machine.img
```

Ou les deux partitions séparément (si tu veux éviter de relancer le self-test) :

```bash
# 1. Code Erlang (contient l'index des sons)
rebar3 atomvm esp32_flash -p COM3 -o 0x130000

# 2. Partition sons
esptool.py --chip esp32c3 --port COM3 write_flash 0x230000 _build/generated/sounds.bin
```

> Note : flasher l'image complète (`write_flash 0`) réinitialise la NVS (calibration) et déclenche le self-test au prochain boot. Les deux partitions séparément préservent la calibration.

### 7. Tester et revenir en arrière

- Pour revenir au code d'origine, repassez sur `main` ou utilisez une image complète de référence.
- Conservez une copie du commit original sur `main`.

## Comment rester sur du 100 % sûr

- Faites vos modifications dans `sounds/` et `choreographies.json` autant que possible.
- Évitez les changements profonds dans le code Erlang si vous souhaitez rester simple.
- Si vous voulez plus tard modifier le comportement interne, on pourra apprendre Erlang petit à petit.

## Phase 2 : interface web

### Fonctionnalités attendues

- Upload de MP3 personnalisés
- Éditeur de scénarios (son + servo)
- Aperçu / preview
- Déploiement vers la machine via USB

### Stack suggérée

- Frontend : Vue 3 + Vite
- Backend simple : Node.js / Express
- Optionnel : Electron si on veut une app desktop

### Workflow cible

1. Lancer l'interface
2. Importer/éditer des sons
3. Créer ou ajuster des scénarios visuels
4. Générer `choreographies.json` ou `sounds.bin`
5. Flasher depuis l'outil

## Note sur l'apprentissage d'Erlang

- Pour l'instant, on peut tout faire avec des données JSON + des MP3.
- Si vous voulez maîtriser la machine plus finement, on regardera ensemble `src/` plus tard.
- Le plus simple pour démarrer est de rester sur `choreographies.json` et `sounds/`.

## Prochaines actions immédiates

1. Installer Erlang/OTP + `rebar3` + `esptool`
2. Tester un build propre sans modification
3. Ajouter le son `sounds/personal/uefachampions_01.mp3`
4. Ajouter un premier scénario dans `choreographies.json`
5. Tenter un upload de la partition sons
