import { render, screen } from '@testing-library/react'
import Home from './page'

describe('Home', () => {
  it('renders Welcome message', () => {
    render(<Home />)
    const message = screen.getByText(/Welcome to the Invader Game! No enemies here, just enjoy the view./i)
    expect(message).toBeInTheDocument()
  })
}) 