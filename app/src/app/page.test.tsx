import { render, screen } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import Home from './page'

describe('Home', () => {
  it('renders counter with initial value of 0', () => {
    render(<Home />)
    const counter = screen.getByRole('heading', { name: /counter/i })
    expect(counter).toHaveTextContent('Counter: 0')
  })

  it('increments counter when increment button is clicked', async () => {
    const user = userEvent.setup()
    render(<Home />)
    const incrementButton = screen.getByRole('button', { name: /increment/i })
    
    await user.click(incrementButton)
    
    const counter = screen.getByRole('heading', { name: /counter/i })
    expect(counter).toHaveTextContent('Counter: 1')
  })

  it('decrements counter when decrement button is clicked', async () => {
    const user = userEvent.setup()
    render(<Home />)
    const decrementButton = screen.getByRole('button', { name: /decrement/i })
    
    await user.click(decrementButton)
    
    const counter = screen.getByRole('heading', { name: /counter/i })
    expect(counter).toHaveTextContent('Counter: -1')
  })
}) 