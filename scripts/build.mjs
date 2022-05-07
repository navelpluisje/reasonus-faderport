#!/usr/bin/env node

import { config as envConfig } from 'dotenv';
import fs from 'fs';
import path from 'path';
import chalk from 'chalk';
import { subtractArgs, copyZoneFile, copyFile } from './utils/index.mjs';

const dotEnv = envConfig();
const args = subtractArgs()

if (!process.env.REAPER_PATH) {
  throw new Error('REAPER_PATH has not been set');
}

if (args._.includes('help')) {
  console.log('HELPPPPP');
  process.exit(0);
}

console.clear()
if (!process.env.ALWAYS_ON_ACTION) {
  console.log(chalk.red('ALWAYS_ON_ACTION is not set.'));
  console.log('The action id will not be replaced and may result in a not proper working FaderPort while developing \n\n\n');
}

if (args._.includes('watch')) {
  console.log(chalk.blue('================================================================================'));
  console.log(chalk.blue('Watching for changes'));
  console.log(chalk.blue('================================================================================\n'));
  fs.watch(
    path.join(process.cwd(), 'src', 'CSI'),
    {
      recursive: true,
    },
    (x, file) => {
      if (!process.env.ALWAYS_ON_ACTION) {
        copyFile(path.join(process.cwd(), 'src', 'CSI'), path.join(process.env.REAPER_PATH, 'CSI'), file);
      } else {
        copyZoneFile(path.join(process.cwd(), 'src', 'CSI', file), path.join(process.env.REAPER_PATH, 'CSI', file), file);
      }
    },
  );
}