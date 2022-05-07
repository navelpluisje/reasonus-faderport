export const subtractArgs = () => (
  process.argv.slice(2).reduce((acc, arg) => {
    const a = arg.split('=');
    return {
      ...acc,
      _: [...acc._, a[0]],
      [a[0]]: a[1] || null,
    }
  }, { _: [] })
);
