#!/usr/bin/env node

import { config as envConfig } from 'dotenv';
import fs from 'fs';
import path from 'path';
import chalk from 'chalk';
import { subtractArgs, copyZoneFile, copyFile } from './utils/index.mjs';
import fse from 'fs-extra';
import { zip } from 'zip-a-folder';

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
// if (!process.env.ALWAYS_ON_ACTION) {
//   console.log(chalk.red('ALWAYS_ON_ACTION is not set.'));
//   console.log('The action id will not be replaced and may result in a not proper working FaderPort while developing \n\n\n');
// }

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
    fs.watch(
    path.join(process.cwd(), 'src', 'Scripts'),
    {
      recursive: true,
    },
    (x, file) => {
      copyFile(path.join(process.cwd(), 'src', 'Scripts'), path.join(process.env.REAPER_PATH, 'Scripts', 'Reasonus'), file);
    },
  );

}

if (args._.includes('build')) {
  console.log(chalk.blue('================================================================================'));
  console.log(chalk.blue('Build for Release'));
  console.log(chalk.blue('================================================================================\n'));

  fse.copy(path.join(process.cwd(), 'src'), path.join(process.cwd(), 'out', 'reasonus-faderport'), async (err) => {

    await zip(path.join(process.cwd(), 'out', 'reasonus-faderport'), path.join(process.cwd(), 'out', 'reasonus-faderport.zip'));
  });


  console.log('GO ONNNNNN')
  // const zipSrc = async () => {

  //   await zip(
  //     path.join(process.cwd(), 'src'),
  //     path.join(process.cwd(), 'src', 'out', 'reasouns-faderport.zip'),
  //   );
  // }

  // zipSrc();
}