#!/bin/bash
pkill -9 -u aptitude aptbus || true;
pkill -9 -u aptitude apteng || true;
pkill -9 -u aptitude aptsrv || true;
pkill -9 -u aptitude aptexe || true;
