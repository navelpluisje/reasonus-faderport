import fs from 'fs';
import chalk from 'chalk';
import path from 'path';

export const copyFile = async(fromDir, toDir, fileName) => {
  if (!fileName) { return; }

  console.log(chalk.green(`${new Date().toISOString()}: `) + chalk.yellow(fileName) + chalk.green(` changed.`));

  fs.copyFile(
    path.join(fromDir, fileName),
    path.join(toDir, fileName),
    0,
    (err) => {
      if (err) {
        // File does not exist anymore. Delete it from the destination
        if (err.code === 'ENOENT') {
          console.log(`* ${chalk.magenta(fileName)} ${chalk.green('does not exist. Remove destination file')}`);
          fs.rm(path.join(toDir, fileName), (err) => {
            if (err) {
              console.log(chalk.red('error delete'), err);
            } else {
              console.log(`* ${chalk.magenta(fileName)} ${chalk.green('Deleted successfully')}`);
            }
          })
        } else {
          console.log(chalk.red('error copy'), err);
        }
      } else {
        console.log(`* ${chalk.yellow(fileName)} ${chalk.green('Copied successfully')}`);
      }
    }
  );
}
