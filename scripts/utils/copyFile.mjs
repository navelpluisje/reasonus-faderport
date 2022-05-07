import fs from 'fs';
import chalk from 'chalk';
import path from 'path';

export const copyFile = (fromDir, toDir, fileName) => {
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
}
