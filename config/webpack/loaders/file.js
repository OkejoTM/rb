const { join } = require('path');
const { source_path: sourcePath } = require('@rails/webpacker/package/config');

module.exports = {
  test: /\.(ico|svg|eot|otf|ttf|woff|woff2)$/i,
  use: [{
    loader: 'file-loader',
    options: {
      name: '[path][name]-[hash].[ext]',
      context: join(sourcePath)
    }
  }]
};
