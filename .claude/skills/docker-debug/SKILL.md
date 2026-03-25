---
name: docker-debug
description: >
  Docker container debugging, log analysis and troubleshooting.
  Use this skill whenever the user has issues with container, docker, log,
  crash, restart, OOMKilled, image, build errors, or anything
  related to containers.
argument-hint: "[container-name]"
allowed-tools: Bash(docker *)
disable-model-invocation: true
---

# Docker debug workflow

## Quick status check
Run the following script to summarize all container states:
```bash
bash ${CLAUDE_SKILL_DIR}/scripts/container-status.sh
```

## Troubleshooting flow

### Container won't start
1. Check logs: `docker logs --tail 50 <container>`
2. Check exit code: `docker inspect --format='{{.State.ExitCode}}' <container>`
3. Check if OOMKilled: `docker inspect --format='{{.State.OOMKilled}}' <container>`

### Container is slow
1. Check resource usage: `docker stats --no-stream <container>`
2. Inspect process list: `docker top <container>`

### Build is failing
1. Clear build cache: `docker builder prune`
2. Identify which stage failed in multi-stage builds
3. Retry while preserving layer cache: `docker build --progress=plain .`

## Common errors and fixes
- **port already in use** → Use `docker ps` to find the conflicting container
- **no space left on device** → Check disk usage with `docker system df`
- **permission denied** → Check volume mount permissions