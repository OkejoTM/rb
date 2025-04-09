module.exports = {
  test: /\.(bmp|gif|jpe?g|png)$/i,
  use: [{
    loader: 'file-loader',
    options: {
      name: '[name]-[hash].[ext]',
      outputPath: 'images/',
    }
  }]
};
