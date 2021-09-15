import { Controller } from '@hotwired/stimulus'
//import Marp from '@marp-team/marpit'

class MarpController extends Controller {

  connect() {
    this.link()
  }

  link() {
    fetch(location.href, {
      method: 'GET',
      headers: {
        Accept: 'application/json'
      }
    }).then(response => {
      return response.json()
    }).then(body => {
      const { html, css, comments } = this.marp.render(body.results.markdown)
      this.installCss(css)
      this.element.innerHTML = html
    })
  }

  installCss(css) {
    const element = document.createElement('style')
    element.type = 'text/css'
    element.id = 'marp_style'
    element.textContent = css
    document.head.insertBefore(element, document.head.lastChild)
  }

  get marp() {
    return new Marp({
      markdown: {
        html: true,
        breaks: true
      }
    })
  }

}

//application.register('marp', MarpController)
