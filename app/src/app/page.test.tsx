import { render, screen, fireEvent } from '@testing-library/react'
import Home from './page'

describe('Home', () => {
  it('renders Welcome message', () => {
    render(<Home />)
    const message = screen.getByText(/Welcome to the Invader Game! No enemies here, just enjoy the view./i)
    expect(message).toBeInTheDocument()
  })

  it('renders the game title', () => {
    const { getByText } = render(<Home />)
    expect(getByText('SPACE INVADERS')).toBeInTheDocument()
  })

  it('renders the player', () => {
    const { container } = render(<Home />)
    const player = container.querySelector('.player')
    expect(player).toBeInTheDocument()
  })

  it('moves player left when left arrow key is pressed', () => {
    const { container } = render(<Home />)
    const player = container.querySelector('.player') as HTMLElement
    const initialLeft = player.style.left

    fireEvent.keyDown(window, { key: 'ArrowLeft' })
    
    expect(player.style.left).not.toBe(initialLeft)
    expect(parseFloat(player.style.left)).toBeLessThan(parseFloat(initialLeft))
  })

  it('moves player right when right arrow key is pressed', () => {
    const { container } = render(<Home />)
    const player = container.querySelector('.player') as HTMLElement
    const initialLeft = player.style.left

    fireEvent.keyDown(window, { key: 'ArrowRight' })
    
    expect(player.style.left).not.toBe(initialLeft)
    expect(parseFloat(player.style.left)).toBeGreaterThan(parseFloat(initialLeft))
  })

  it('does not move player beyond left boundary', () => {
    const { container } = render(<Home />)
    const player = container.querySelector('.player') as HTMLElement

    // Move left multiple times to hit boundary
    for (let i = 0; i < 20; i++) {
      fireEvent.keyDown(window, { key: 'ArrowLeft' })
    }
    
    expect(parseFloat(player.style.left)).toBe(0)
  })

  it('does not move player beyond right boundary', () => {
    const { container } = render(<Home />)
    const player = container.querySelector('.player') as HTMLElement

    // Move right multiple times to hit boundary
    for (let i = 0; i < 20; i++) {
      fireEvent.keyDown(window, { key: 'ArrowRight' })
    }
    
    expect(parseFloat(player.style.left)).toBe(100)
  })
}) 