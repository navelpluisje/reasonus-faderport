import fs from 'fs';
import chalk from 'chalk';
import path from 'path';

export const copyFile = (fromDir, toDir, fileName) => {
  console.log(chalk.green(`${new Date().toISOString()}: `) + chalk.yellow(fileName) + chalk.green(` changed.`));

  const toFile = path.join(toDir, fileName);
  const toFileDir = toFile.split(
    '/',
    toFile.split('/').length - 1
  ).join('/');

  if (!fs.existsSync(toFileDir)) {
    fs.mkdirSync(toFileDir, { recursive: true })
  }
  fs.copyFile(
    path.join(fromDir, fileName),
    path.join(toDir, fileName),
    0,
    (err) => {
      if (err) {
        console.log(chalk.red('error'), err);
      } else {
        console.log(`* ${chalk.yellow(fileName)} ${chalk.green('Copied successfully')}`);
      }
    }
  );
}
