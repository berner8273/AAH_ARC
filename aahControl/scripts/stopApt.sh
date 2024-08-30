#!/usr/bin/env bash
printf "Stopping Aptitude ...$p\n"
pkill -9 -u aptitude aptexe || true;
pkill -9 -u aptitude aptbus || true;
pkill -9 -u aptitude apteng || true;
pkill -9 -u aptitude aptsrv || true;
