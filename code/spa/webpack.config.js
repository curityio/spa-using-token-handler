const path = require('path');
const webpack = require('webpack');

module.exports = {

  mode: 'production',
  context: path.resolve(__dirname, 'src'),

  // The example supports the 4 main desktop browsers and the 2 main mobile browsers
  target: ['web', 'es2017'],

  entry: {
    app: ['./index.tsx']
  },
  module: {

    rules: [
      {
        test: /\.(ts|tsx)$/,
        use: 'ts-loader',
        exclude: /node_modules/
      }
    ]
  },
  resolve: {
    extensions: ['.ts', '.tsx', '.js']
  },
  output: {
    path: path.resolve(__dirname, 'dist'),
    filename: `[name].bundle.js`,
  },
  optimization: {

    splitChunks: {
      cacheGroups: {
        vendor: {
          chunks: 'initial',
          name: 'vendor',
          test: /node_modules/,
          enforce: true
        },
      }
    }
  }
}
