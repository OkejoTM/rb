const { execSync } = require('child_process');

const resolvedGemsString = execSync('bundle exec bin/gem_resolver').toString();
// Парсим два раза потому, что результат resolvedGemsString находится в кавычках
// т.е. parse("'{}'") => '{}', parse('{}') => {}
const resolvedGems = JSON.parse(JSON.parse(resolvedGemsString));

module.exports = {
  resolvedGems
};
