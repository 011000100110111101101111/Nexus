import { animate, inView, stagger } from 'motion'

// animate('img', {
//   y: ['-50px', '0px'],
//   height: ['0px', '200px'],
// },
// {
//   delay: stagger(1.5)
// })

inView('section', ({ target }) => {
  animate(
    target.querySelectorAll('img'), {
      height: ['0px', '200px'],
      transform: "none"
    },
  { delay: stagger(0.3), duration: 1.2, easing: [0.17, 0.55, 0.55, 1]}
  ),
  animate(
    target.querySelectorAll('h3'), {
      oppacity: ['0', '1'],
      y: ['-50px', '0px'],
    },
  { delay: stagger(1), duration: 1.2, easing: [0.17, 0.55, 0.55, 1]}
  ),
  animate(
    target.querySelectorAll('p'), {
      oppacity: ['0', '1'],
      y: ['-200px', '0px'],
    },
  { delay: stagger(1), duration: 1.2, easing: [0.17, 0.55, 0.55, 1]}
  )
})