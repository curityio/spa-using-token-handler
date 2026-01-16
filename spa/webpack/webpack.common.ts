import CopyPlugin from 'copy-webpack-plugin';
import path from 'path';

const dirname = process.cwd();
export default {

  context: path.resolve(dirname, '.'),
  target: ['web'],
  devtool: 'source-map',

  entry: {
    app: ['./src/index.tsx']
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
    path: path.resolve(dirname, './dist'),
    filename: `[name].bundle.js`,
    clean: true,
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
  },
  plugins: [

    new CopyPlugin({
      patterns: [
        {
          from: 'index.html',
          to: path.resolve('dist'),
        },
        {
          from: 'css',
          to: path.resolve('dist'),
        },
        {
          from: 'config.json',
          to: path.resolve('dist'),
        },
      ]
    }),
  ]
}
