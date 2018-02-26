/**
 * Copyright (c) 2017-present, Facebook, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

const React = require('react');

class Footer extends React.Component {
  docUrl(doc, language) {
    const baseUrl = this.props.config.baseUrl;
    return baseUrl + 'docs/' + (language ? language + '/' : '') + doc;
  }

  pageUrl(doc, language) {
    const baseUrl = this.props.config.baseUrl;
    return baseUrl + (language ? language + '/' : '') + doc;
  }

  render() {
    const currentYear = new Date().getFullYear();

    const yearLabel = currentYear > 2018 ? `2018–${currentYear}` : currentYear;

    return (
      <footer className="nav-footer" id="footer">
        <section className="sitemap">
          <div className="footer--block">
            <h5>Project</h5>
            <div className="footer--list--item">
              <a href={this.props.config.repoUrl} target="_blank">
                GitHub
              </a>
            </div>
            <div className="footer--list--item">
              <a href={this.props.config.gemUrl} target="_blank">
                RubyGems
              </a>
            </div>
          </div>
          {/* <div className="footer--block">
            <h5>Community</h5>
              <div className="footer--list--item">
                <a href="https://discordapp.com/" target="_blank">Project Chat</a>
              </div>
              <div className="footer--list--item">
                <a href="https://twitter.com/" target="_blank">
                  Twitter
                </a>
              </div>
          </div>
          <div className="footer--block">
            <h5>Resources</h5>
              <div className="footer--list--item">
                <a href="#" target="_blank">Super puper chronicles post</a>
              </div>
              <div className="footer--list--item">
                <a href="#" target="_blank">
                  Talk Slides
                </a>
              </div>
          </div> */}
          <div className="footer--block legals">
            <p className="footer--copy">
              <span className="copy">{yearLabel}</span>&nbsp;
              <a href="https://evilmartians.com" target="_blank">Evil Martians</a>
            </p>
            <div className="footer--list--item">
              <p>Released under the <a href="https://github.com/palkan/clowne/blob/master/LICENSE.txt" target="_blank">MIT license</a></p>
            </div>
            <div className="footer--list--item">
              <p>Built with <a href="https://docusaurus.io" target="_blank">Docusaurus</a></p>
            </div>
          </div>
        </section>
        <div className="footer--humanoids">
          <div className="humanoids">
            <div className="humanoids__martian">
              <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 108 92"><path fill="#E2CBB5" d="M26 88L8 78l18-10"></path><path fill="#9FA628" d="M94 92v-6H44c-5.5 0-10-4.5-10-10s4.5-10 10-10h50V32c0-14-7.9-22-22-22H48c-14.1 0-22 8-22 22v60h68z"></path><circle fill="#FFF" cx="48" cy="50" r="8"></circle><circle fill="#FFF" cx="72" cy="50" r="8"></circle><circle fill="#BF6C35" cx="48" cy="50" r="4"></circle><circle fill="#BF6C35" cx="72" cy="50" r="4"></circle><g fill="#663F4C"><path d="M48 60c-5.5 0-10-4.5-10-10s4.5-10 10-10 10 4.5 10 10-4.5 10-10 10zm0-16c-3.3 0-6 2.7-6 6s2.7 6 6 6 6-2.7 6-6-2.7-6-6-6zM82 50c0 5.5-4.5 10-10 10s-10-4.5-10-10 4.5-10 10-10 10 4.5 10 10zm-16 0c0 3.3 2.7 6 6 6s6-2.7 6-6-2.7-6-6-6-6 2.7-6 6z"></path><path d="M102 8c-3.8 0-6-2.2-6-6 0-1.1-.9-2-2-2s-2 .9-2 2c0 2.2.5 4.1 1.5 5.7L88.2 13c-4-3.3-9.5-5-16.2-5H48c-6.7 0-12.2 1.7-16.2 4.9l-5.3-5.3C27.5 6.1 28 4.2 28 2c0-1.1-.9-2-2-2s-2 .9-2 2c0 3.8-2.2 6-6 6-1.1 0-2 .9-2 2s.9 2 2 2c2.2 0 4.1-.5 5.7-1.5l5.3 5.3c-3.2 4-4.9 9.5-4.9 16.2v34.8L3.9 78 24 89v3h4V32c0-12.9 7.1-20 20-20h24c12.9 0 20 7.1 20 20v32H44c-6.6 0-12 5.4-12 12s5.4 12 12 12h48v4h4v-8h-2l-4-8-4 8h-4l-4-8-4 8h-4l-4-8-4 8h-4l-4-8-4 8h-4l-4-8-3.1 6.2C37.1 80.7 36 78.5 36 76c0-4.4 3.6-8 8-8l4 8 4-8h4l4 8 4-8h4l4 8 4-8h4l4 8 4-8h8V32c0-6.7-1.7-12.2-4.9-16.2l5.3-5.3c1.6 1 3.5 1.5 5.7 1.5 1.1 0 2-.9 2-2s-1-2-2.1-2zM24 84.4L12.1 78 24 71.4v13z"></path></g></svg>
            </div>
            <div className="humanoids__human">
              <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 108 92"><path fill="#E2CBB5" d="M14 62v30h68v-6H32c-5.5 0-10-4.5-10-10s4.5-10 10-10h50v-4c4 0 8-3.6 8-8s-4-8-8-8V32c0-14-7.9-22-22-22H36c-14.1 0-22 8-22 22v14c-4 0-8 3.6-8 8s4 8 8 8z"></path><circle fill="#FFF" cx="36" cy="50" r="8"></circle><circle fill="#FFF" cx="60" cy="50" r="8"></circle><circle fill="#9FA628" cx="36" cy="50" r="4"></circle><circle fill="#9FA628" cx="60" cy="50" r="4"></circle><path fill="#BF6C35" d="M60 10H36c-14.1 0-22 8-22 22v2l4-4 6 6 6-6 6 6 6-6 6 6 6-6 6 6 6-6 6 6 6-6 4 4v-2c0-14-7.9-22-22-22z"></path><g fill="#663F4C"><path d="M36 60c-5.5 0-10-4.5-10-10s4.5-10 10-10 10 4.5 10 10-4.5 10-10 10zm0-16c-3.3 0-6 2.7-6 6s2.7 6 6 6 6-2.7 6-6-2.7-6-6-6zM60 60c-5.5 0-10-4.5-10-10s4.5-10 10-10 10 4.5 10 10-4.5 10-10 10zm0-16c-3.3 0-6 2.7-6 6s2.7 6 6 6 6-2.7 6-6-2.7-6-6-6z"></path><path d="M12 63.8V92h4V32c0-12.9 7.1-20 20-20h24c12.9 0 20 7.1 20 20v32H32c-6.6 0-12 5.4-12 12s5.4 12 12 12h48v4h4v-8H74v-1c0-1.7-1.3-3-3-3s-3 1.3-3 3v1h-6v-1c0-1.7-1.3-3-3-3s-3 1.3-3 3v1h-6v-1c0-1.7-1.3-3-3-3s-3 1.3-3 3v1h-6v-1c0-1.7-1.3-3-3-3s-3 1.3-3 3v1c-4 0-8-3.6-8-8s3.6-8 8-8h6v1c0 1.7 1.3 3 3 3s3-1.3 3-3v-1h6v1c0 1.7 1.3 3 3 3s3-1.3 3-3v-1h6v1c0 1.7 1.3 3 3 3s3-1.3 3-3v-1h6v1c0 1.7 1.3 3 3 3s3-1.3 3-3v-1h4v-4.2c5-.9 8-5 8-9.8s-3-8.9-8-9.8V32c0-15.3-8.7-24-24-24H36c-15.3 0-24 8.7-24 24v12.2c-5 .9-8 5-8 9.8s3 8.9 8 9.8zm72-15.5c2 .8 4 3 4 5.7s-2 4.8-4 5.7V48.3zm-72 0v11.3c-2-.8-4-3-4-5.7s2-4.7 4-5.6z"></path></g></svg>
            </div>
          </div>
        </div>
      </footer>
    );
  }
}

module.exports = Footer;
