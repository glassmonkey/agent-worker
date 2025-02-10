import { render, screen } from '@testing-library/react'
import Home from './page'

describe('Home', () => {
  it('renders hello world', () => {
    render(<Home />)
    const main = screen.getByRole('main')
    expect(main).toHaveTextContent('Hello World')
  })
}) 