#!/usr/bin/env node

const dotEnv = require('dotenv').config();
const fs = require('fs');
const path = require('path');
const chalk = require('chalk');
const args = require('./utils').subtractArgs();

if (!process.env.REAPER_PATH) {
    throw new Error('REAPER_PATH has not been set');
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
        },
    );
    return;
}