import React, { Component } from 'react'
import styled from 'styled-components'
import { Button } from 'react-bootstrap'

const Add = styled.small`
  cursor: pointer;
`

const Input = styled.input`
  height: 30px;
  width: 50%;
`

const FormButton = styled(Button)`
  margin-left: 10px;
`

class AddKeyResult extends Component {
  state = {
    adding: false,
    keyResultText: ''
  }

  cancel = () => {
    this.setState({
      adding: false,
      keyResultText: '',
    })
  }

  keyResultTextChange = (evt) => {
    this.setState({
      keyResultText: evt.target.value,
    })
  }

  submitForm = (evt) => {
    evt.preventDefault()
    const { objectiveId, saveFn } = this.props
    const { keyResultText } = this.state

    saveFn({ objective_id: objectiveId, content: keyResultText }).then(() => {
      this.cancel()
    })
  }

  render() {
    const { adding, keyResultText } = this.state

    if (adding) {
      return (
        <div>
          <form onSubmit={this.submitForm}>
            <Input autoFocus value={keyResultText} onChange={this.keyResultTextChange} required />
            <FormButton type="submit" bsClass="btn-xs btn-primary">Add</FormButton>
            <FormButton type="button" bsClass="btn-xs" onClick={this.cancel}>Cancel</FormButton>
          </form>
        </div>
      )
    } else {
      return (
        <div>
          <Add onClick={() => this.setState({ adding: true })}>+ Add Key result</Add>
        </div>
      )
    }
  }
}

export default AddKeyResult
