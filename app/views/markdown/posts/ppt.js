import { Controller } from '@hotwired/stimulus'
import { Marpit } from '@marp-team/marpit'
import './marp_item'

class MarpController extends Controller {
  static targets = ['container']

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
      const { html, css, comments } = this.marp.render(body.results.markdown, { htmlAsArray: true })
      this.installCss(css)
      this.slides = html
      this.containerTarget.innerHTML = this.slides[0]
    })
  }

  prev() {
    const page = this.currentPage - 2
    this.containerTarget.innerHTML = this.slides[page]
  }

  next() {
    const page = this.currentPage
    this.containerTarget.innerHTML = this.slides[page]
  }

  installCss(css) {
    const element = document.createElement('style')
    element.type = 'text/css'
    element.id = 'marp_style'
    element.textContent = css
    document.head.insertBefore(element, document.head.lastChild)
  }

  set slides(arr) {
    this.slices = arr
  }

  get slides() {
    return this.slices
  }

  get currentPage() {
    return this.containerTarget.firstChild.dataset.marpitPagination
  }

  get marp() {
    return new Marpit({
      markdown: {
        html: true,
        breaks: true
      }
    })
  }

}

application.register('marp', MarpController)
