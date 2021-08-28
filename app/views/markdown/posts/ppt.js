import { Controller } from 'stimulus'
import Marp from '@marp-team/marpit'

class MarpController extends Controller {

  connect() {
    console.debug('connected:', this.identifier)
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
      console.log(css)
      this.element.innerHTML = html
    })
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

application.register('marp', MarpController)
