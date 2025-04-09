const { environment } = require('@rails/webpacker');
const erb = require('./loaders/erb');
const vue = require('./loaders/vue');
const file = require('./loaders/file');
const images = require('./loaders/images');

const webpack = require('webpack');
const { resolvedGems } = require('./loaders/gem');

resolvedGems['gems'].forEach((gemPair) => {
  environment.resolvedModules.add({
    key: gemPair['gem_name'],
    value: gemPair['gem_path']
  });
});


// Add an ProvidePlugin
environment.plugins.prepend('Provide', new webpack.ProvidePlugin({
  _: 'lodash',
  $: 'jquery',
  jQuery: 'jquery',
  jquery: 'jquery',
  Popper: ['popper.js', 'default'],
  Tooltip: 'bootstrap/js/dist/tooltip',
  ActionCable: 'actioncable',
  App: 'actioncable',
  Vue: 'vue',
  VueResource: 'vue-resource',
  Masonry: 'masonry-layout',
  jQueryBridget: 'jquery-bridget',
  i18next: 'i18next',
  ClassicEditor: '@ckeditor/ckeditor5-build-classic'
}));

// resolve-url-loader must be used before sass-loader
environment.loaders.get('sass').use.splice(-2, 0, {
  loader: 'resolve-url-loader',
  options: {
    attempts: 1,
    sourceMap: true
  }
});

const config = environment.toWebpackConfig();

config.resolve.alias = {
  jquery: "jquery/src/jquery",
  vue: "vue/dist/vue.js",
  vue_resource: "vue-resource/dist/vue-resource",
  waypoints: 'waypoints/lib/jquery.waypoints.js'
};

environment.loaders.append('images', images);
//Перезаписывает стандартную настройку file-loader wepacker
Object.assign(environment.loaders.get('file'), file);
environment.loaders.append('erb', erb);
environment.loaders.append('vue', vue);

module.exports = environment;
