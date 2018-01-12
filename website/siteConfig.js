/**
 * Copyright (c) 2017-present, Facebook, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

/* List of projects/orgs using your project for the users page */
const users = [
  {
    caption: 'User1',
    image: '/test-site/img/docusaurus.svg',
    infoLink: 'https://www.facebook.com',
    pinned: true,
  },
];

const siteConfig = {
  title: 'Clowne' /* title for your website */,
  tagline: 'A flexible gem for cloning your models.',
  url: 'https://github.com/palkan/clowne' /* your website url */,
  baseUrl: '/clowne/' /* base url for your project */,
  projectName: 'clowne',
  headerLinks: [
    {doc: 'basic_example', label: 'Docs'},
    {blog: true, label: 'Blog'},
    {href: 'https://github.com/palkan/clowne', label: 'GitHub'},
  ],
  users: [], /* users, */
  /* path to images for header/footer */
  headerIcon: 'img/docusaurus.svg',
  footerIcon: 'img/docusaurus.svg',
  favicon: 'img/favicon.png',
  /* colors for website */
  colors: {
    primaryColor: '#7d638e', /* #2E8555 */
    secondaryColor: '#205C3B',
  },
  // This copyright info is used in /core/Footer.js and blog rss/atom feeds.
  copyright:
    'Copyright © ' +
    new Date().getFullYear() +
    ' Evil Martians',
  // organizationName: 'deltice', // or set an env variable ORGANIZATION_NAME
  highlight: {
    // Highlight.js theme to use for syntax highlighting in code blocks
    theme: 'default',
  },
  scripts: ['https://buttons.github.io/buttons.js'],
  // You may provide arbitrary config keys to be used as needed by your template.
  repoUrl: 'https://github.com/palkan/clowne',
};

module.exports = siteConfig;
