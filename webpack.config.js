var path = require('path');

module.exports = {
  entry: './src/main.coffee',
  output: {
    path: path.resolve(__dirname, 'dist'),
    filename: 'main.js',
    library: 'Skateboard',
    libraryTarget: 'umd'
  },
  module: {
    rules: [
      {
        test: /\.coffee$/,
        use: ['coffee-loader']
      }
    ]
  },
  externals: {
    jquery: {
      commonjs2: 'jquery',
      commonjs: 'jquery',
      amd: 'jquery',
      root: '$'
    }
  }
};
