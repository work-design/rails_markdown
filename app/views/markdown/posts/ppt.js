import { Controller } from '@hotwired/stimulus'
import { Marp } from '@marp-team/marp-core'
import './marp_item'
import hljs from 'highlight.js'

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
      this.comments = comments
      this.containerTarget.innerHTML = this.slides[0]
    })
  }

  prev() {
    const page = this.currentPage - 2
    this.containerTarget.innerHTML = this.slides[page]
    console.log(this.comments[page])
    this.containerTarget.querySelectorAll('code').forEach(el => {
      hljs.highlightElement(el)
    })
  }

  next() {
    const page = this.currentPage
    this.containerTarget.innerHTML = this.slides[page]
    console.log(this.comments[page])
    this.containerTarget.querySelectorAll('code').forEach(el => {
      hljs.highlightElement(el)
    })
  }

  keyboard(e) {
    switch(e.which) {
      case 37: // left
        return this.prev()
      case 39: // right
        return this.next()
      default: return
    }
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
    return this.containerTarget.querySelector('section').dataset.marpitPagination
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
