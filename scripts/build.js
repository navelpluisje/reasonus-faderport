#!/usr/bin/env node

const dotEnv = require('dotenv').config();
const fs = require('fs');
const path = require('path');
const chalk = require('chalk');
const args = require('./utils').subtractArgs();

if (!process.env.REAPER_PATH) {
  throw new Error('REAPER_PATH has not been set');
}

console.clear()
if (!process.env.ALWAYS_ON_ACTION) {
  console.log(chalk.red('ALWAYS_ON_ACTION is not set.'));
  console.log('The action id will not be replaced and may result in a not proper working FaderPort while developing \n\n\n');
}

if (args._.includes('help')) {
  console.log('HELPPPPP');
  return;
}

if (args._.includes('watch')) {
  console.log(chalk.blue('================================================================================'));
  console.log(chalk.blue('Watching for changes'));
  console.log(chalk.blue('================================================================================\n'));
  fs.watch(
    path.join(process.cwd(), 'src'),
    {
      recursive: true,
    },
    (x, file) => {
      console.log(chalk.green(`${new Date().toISOString()}: `) + chalk.yellow(file) + chalk.green(` changed.`));
      if (!process.env.ALWAYS_ON_ACTION) {
        fs.copyFile(
          path.join(process.cwd(), 'src', file),
          path.join(process.env.REAPER_PATH, 'CSI', file),
          0,
          (err) => {
            if (err) {
              console.log(chalk.red('error'), err);
            } else {
              console.log(`* ${chalk.yellow(file)} ${chalk.green('Copied successfully')}`);
            }
          }
        );
      } else {
        const changedFilePath = path.join(process.cwd(), 'src', file);
        const destFileName = path.join(process.env.REAPER_PATH, 'CSI', file)
        const fileContent = fs.readFileSync(changedFilePath).toString();
        try {
          fs.writeFileSync(destFileName, fileContent.replace(/%dummyAction%/g, process.env.ALWAYS_ON_ACTION));
          console.log(`* ${chalk.yellow(file)} ${chalk.green('Copied successfully')}`);
        } catch (err) {
          console.log(chalk.red('error'), err);
        }
      }
    },
  );
  return;
}