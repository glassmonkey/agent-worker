import { render, screen } from '@testing-library/react'
import Home from './page'
import '@testing-library/jest-dom'

describe('Home', () => {
  it('renders game title', () => {
    render(<Home />)
    const title = screen.getByText('SPACE INVADERS')
    expect(title).toBeInTheDocument()
  })

  it('renders shoot instruction', () => {
    render(<Home />)
    const instruction = screen.getByText('Press SPACE to shoot!')
    expect(instruction).toBeInTheDocument()
  })
}) 