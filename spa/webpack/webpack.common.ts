import path from 'path';

const dirname = process.cwd();
export default {

  context: path.resolve(dirname, './src'),
  target: ['web'],

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
    path: path.resolve(dirname, './dist'),
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
