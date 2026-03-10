# Docker + WSL Dev Reference

## WSL Basics

```bash
pwd               # where am I?
cd my-app         # go into folder
cd ..             # go up one level
ls                # list files
mkdir my-folder   # create folder
rm -rf my-folder  # delete folder (no undo!)
```

**Permission denied?** Docker creates files as root. Fix with:
```bash
sudo chown -R $USER:$USER .
```

---

## Docker

```bash
docker compose build        # build image (first time, or after Gemfile changes)
docker compose up           # start app → http://localhost:3000
docker compose up -d        # start in background
docker compose down         # stop containers
docker compose logs -f      # view live logs
```

---

## Running Rails Commands

Containers must be running first (`docker compose up`).

```bash
docker compose exec web rails db:create
docker compose exec web rails db:migrate
docker compose exec web rails generate controller Pages index
docker compose exec web rails routes
docker compose exec web rails console
docker compose exec web bundle install
```

Need a shell inside the container?
```bash
docker compose exec web bash
# now run rails commands directly, exit when done
```

---

## Git

```bash
git pull                        # get latest changes
git checkout -b my-branch       # create & switch to new branch
git checkout my-branch          # switch to existing branch
git add .                       # stage all changes
git commit -m "your message"    # commit
git push origin my-branch       # push to remote
```

---

## Common Workflows

**New gem** → add to `Gemfile`, then:
```bash
docker compose exec web bundle install
```

**Reset DB:**
```bash
docker compose exec web rails db:drop db:create db:migrate db:seed
```

**Full rebuild** (when things break):
```bash
docker compose down -v
docker compose up --build
```
