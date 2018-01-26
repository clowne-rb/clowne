/**
 * Copyright (c) 2017-present, Facebook, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

const siteConfig = {
  title: 'Clowne' /* title for your website */,
  tagline: 'A flexible gem for cloning your models',
  url: 'https://github.com/palkan/clowne' /* your website url */,
  baseUrl: '/clowne/' /* base url for your project */,
  customDocsPath: '../docs',
  projectName: 'clowne',
  headerLinks: [
    {doc: 'basic_example', label: 'Docs'},
    {href: 'https://github.com/palkan/clowne', label: 'GitHub'},
  ],
  users: [], /* users, */
  /* path to images for header/footer */
  // headerIcon: 'img/docusaurus.svg',
  favicon: 'img/favicon/favicon.ico',
  /* colors for website */
  colors: {
    primaryColor: '#ff5e5e', /* #2E8555 */
    secondaryColor: '#e3e3e3',
  },
  // This copyright info is used in /core/Footer.js and blog rss/atom feeds.
  copyright:
    'Copyright © ' +
    new Date().getFullYear() +
    ' Evil Martians',
  // organizationName: 'deltice', // or set an env variable ORGANIZATION_NAME
  highlight: {
    // Highlight.js theme to use for syntax highlighting in code blocks
    theme: 'ascetic',    
  },
  scripts: ['https://buttons.github.io/buttons.js'],
  // You may provide arbitrary config keys to be used as needed by your template.
  repoUrl: 'https://github.com/palkan/clowne',
  gemUrl: 'https://rubygems.org/gems/clowne',
};

module.exports = siteConfig;
