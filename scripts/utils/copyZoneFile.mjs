import fs from 'fs';
import chalk from 'chalk';

export const copyZoneFile = (srcFilePath, destFileName, file) => {
  console.log(chalk.green(`${new Date().toISOString()}: `) + chalk.yellow(file) + chalk.green(` changed.`));
  const fileContent = fs.readFileSync(srcFilePath).toString();

  try {
    fs.writeFileSync(destFileName, fileContent.replace(/%dummyAction%/g, process.env.ALWAYS_ON_ACTION));
    console.log(`* ${chalk.yellow(file)} ${chalk.green('Copied successfully')}`);
  } catch (err) {
    console.log(chalk.red('error'), err);
  }

}