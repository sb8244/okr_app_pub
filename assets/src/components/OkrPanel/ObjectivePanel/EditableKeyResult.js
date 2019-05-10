import React, { Component } from 'react'
import { Button, FormControl } from 'react-bootstrap'
import styled from 'styled-components'

import { KeyResult } from '@utils/api'

const GrowForm = styled.form`
  flex-grow: 1
`

const FormButton = styled(Button)`
  margin-top: 10px;
  margin-right: 10px;
`

export default class EditableKeyResult extends Component {
  state = {
    editing: false,
    editingValue: ''
  }

  setEditing(editing) {
    if (editing) {
      this.setState({ editingValue: this.props.keyResult.content })
    }

    this.setState({ editing })
    this.props.onEditingChange(editing)
  }

  submitForm = (evt) => {
    evt.preventDefault()
    const { okr, keyResult } = this.props
    const { editingValue } = this.state

    KeyResult.update(keyResult.id, { content: editingValue }).then(() => {
      okr.keyResultUpdated().then(() => {
        this.setEditing(false)
      })
    })
  }

  render() {
    const { keyResult } = this.props
    const { editing, editingValue } = this.state

    if (editing) {
      return (
        <GrowForm onSubmit={this.submitForm}>
          <FormControl
            autoFocus
            type="text"
            value={editingValue}
            onChange={(evt) => { this.setState({ editingValue: evt.target.value }) }}
          />
          <FormButton type="submit" bsClass="btn-xs btn-primary">Update</FormButton>
          <FormButton type="button" bsClass="btn-xs"  onClick={() => this.setEditing(false)}>Cancel</FormButton>
        </GrowForm>
      )
    } else {
      return (
        <span onClick={() => this.setEditing(true)}>{keyResult.content}</span>
      )
    }
  }
}
