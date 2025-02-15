import { render, screen } from '@testing-library/react'
import Home from './page'

describe('Home', () => {
  it('renders Hello World message', () => {
    render(<Home />)
    const heading = screen.getByRole('heading', { name: /hello world/i })
    expect(heading).toBeInTheDocument()
  })
}) 