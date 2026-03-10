# Rails 7 + Docker on WSL — Reference Guide

---

## 1. WSL Terminal Basics

These are Linux commands you'll use every day in your Ubuntu terminal.

### Moving Around

```bash
pwd
```
**Print Working Directory.** Shows where you are right now. Example output: `/home/mihai/my-rails-app`.

```bash
cd my-rails-app
```
**Change Directory.** Moves you into a folder. Think of it like double-clicking a folder in Windows.

```bash
cd ..
```
Goes **up** one level. If you're in `~/my-rails-app`, this takes you back to `~` (your home folder).

```bash
cd ~
```
Jumps straight to your **home directory**, no matter where you are.

```bash
ls
```
**List.** Shows all files and folders in your current location.

```bash
ls -la
```
Same as `ls` but shows **hidden files** (ones starting with `.`) and extra details like permissions and file sizes.

### Creating and Deleting

```bash
mkdir my-folder
```
**Make Directory.** Creates a new folder.

```bash
touch somefile.txt
```
Creates an empty file.

```bash
rm somefile.txt
```
**Remove.** Deletes a file. Gone forever — there's no recycle bin.

```bash
rm -rf my-folder
```
Deletes a folder and everything inside it. The `-r` means recursive (go into subfolders), `-f` means force (don't ask me for confirmation). **Be careful with this one.**

### Fixing Ownership (Important with Docker)

Docker runs as root, so sometimes it creates files that **you** can't edit or delete. You'll see "Permission denied" errors. Fix it with:

```bash
sudo chown -R mihai:mihai /home/mihai/my-rails-app
```

Breaking this down:

- `sudo` — run as administrator (it'll ask for your password)
- `chown` — **change owner**
- `-R` — recursive, apply to every file and subfolder inside
- `mihai:mihai` — the new owner and group (replace with your actual WSL username)
- `/home/mihai/my-rails-app` — the path to fix

A shorter version if you're already inside the project folder:

```bash
sudo chown -R $USER:$USER .
```

`$USER` automatically uses your username, and `.` means "this folder".

---

## 2. Building and Starting the Containers

All commands below assume you're inside your project folder:

```bash
cd ~/my-rails-app
```

### Build the images

```bash
docker compose build
```

This reads the `Dockerfile` and creates an **image** — a snapshot of a mini-computer with Ruby, Rails, and all your gems baked in. You only need to do this the first time, or after changing the `Dockerfile` or `Gemfile`.

### Start the containers

```bash
docker compose up
```

This starts **two containers**: the Rails web app and the PostgreSQL database. Logs will stream in your terminal. When you see:

```
web-1  | * Listening on http://0.0.0.0:3000
```

your app is live at **http://localhost:3000**.

### Start in the background

```bash
docker compose up -d
```

The `-d` flag means **detached** — containers run silently in the background. Your terminal stays free. To see what's happening:

```bash
docker compose logs -f
```

`-f` means **follow** — it streams new log lines in real time. `Ctrl+C` to stop watching (the containers keep running).

### Stop the containers

If running in the foreground: press **Ctrl+C**.

If running in the background (or to clean up):

```bash
docker compose down
```

This stops and removes the containers. Your code and database data are safe — they live on your disk, not inside the container.

### Build and start in one command

```bash
docker compose up --build
```

Combines `build` + `up`. Use this after changing your `Dockerfile` or `Gemfile` so you don't forget to rebuild.

### Full rebuild (nuclear option)

```bash
docker compose down -v
docker compose build --no-cache
docker compose up
```

- `-v` removes **volumes**, meaning your database is wiped clean
- `--no-cache` rebuilds everything from scratch, ignoring cached layers

Only do this when something is truly broken.

### Check what's running

```bash
docker compose ps
```

Shows all your containers and their status (running, exited, etc).

---

## 3. Running Rails / Ruby Commands with Docker

This is the most important section. Your Rails app lives **inside** the container, so you can't just type `rails something` in your normal terminal — Ruby isn't installed there. You have two ways to run commands inside the container: **`exec`** and **`run`**.

### exec — talk to a running container

**Requires `docker compose up` to already be running.**

```bash
docker compose exec web <command>
```

- `exec` = execute a command inside an **already running** container
- `web` = the service name from your `docker-compose.yml`
- `<command>` = whatever you want to run

Examples:

```bash
docker compose exec web rails db:create
docker compose exec web rails db:migrate
docker compose exec web rails generate scaffold Post title:string body:text
docker compose exec web rails generate controller Pages home about
docker compose exec web rails routes
docker compose exec web rails console
docker compose exec web bundle install
docker compose exec web ruby -v
```

This is the command you'll use **95% of the time**. It's fast because the container is already running.

### run — spin up a temporary container

**Works even when containers are stopped.**

```bash
docker compose run web <command>
```

- `run` = create a **new, temporary** container, execute the command, then remove it
- It's slower because it boots up a fresh container every time

Examples:

```bash
docker compose run web rails db:create
docker compose run web bundle install
docker compose run web rails new . --force --database=postgresql
```

Use `run` when your containers are stopped and you need to do something quick without starting everything up.

The `--no-deps` flag skips starting linked services (like the database):

```bash
docker compose run --no-deps web bundle lock --add-platform x86_64-linux
```

Useful when the command doesn't need the database.

### Getting a bash shell inside the container

Instead of running one command at a time, you can **get inside** the container and work there interactively:

```bash
docker compose exec web bash
```

Your prompt changes to something like:

```
root@abc123:/app#
```

You're now **inside the container**. Ruby and Rails are available directly:

```bash
rails db:migrate
rails console
bundle install
rake assets:precompile
ruby -v
irb
```

Type `exit` to leave and return to your normal WSL terminal.

If containers are stopped, use `run` instead:

```bash
docker compose run web bash
```

### exec vs run — when to use which

| | `exec` | `run` |
|---|---|---|
| Containers must be running? | Yes | No |
| Speed | Fast (uses existing container) | Slower (starts a new one) |
| Use for | Day-to-day commands | One-off tasks, setup steps |
| Example | `exec web rails console` | `run web rails db:create` |

### Common Rails workflows

**Generate something and migrate:**

```bash
docker compose exec web rails generate scaffold Post title:string body:text
docker compose exec web rails db:migrate
```

**Install a new gem:**

1. Edit your `Gemfile` in your normal editor and add the gem
2. Then:

```bash
docker compose exec web bundle install
```

3. If the container won't start after this, rebuild:

```bash
docker compose up --build
```

**Open the Rails console (like IRB but with your app loaded):**

```bash
docker compose exec web rails console
```

**Reset the database:**

```bash
docker compose exec web rails db:drop db:create db:migrate db:seed
```

**Run tests:**

```bash
docker compose exec web rails test
```

**Check database status:**

```bash
docker compose exec web rails db:migrate:status
```