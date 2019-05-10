import React, { Component } from 'react'
import styled from 'styled-components'
import _ from 'lodash'
import { Button, Panel } from 'react-bootstrap'

import { Objective } from '@utils/api'

const Add = styled.small`
  cursor: pointer;
`

const Input = styled.input`
  height: 30px;
  width: 50%;
`

const FormButton = styled(Button)`
  &:not(:first-child) {
    margin-left: 10px;
  }
`

const KeyResultList = styled('ul')`
  list-style: none;
`

const KeyResult = styled('li')`
  margin-bottom: 10px;
`

const Para = styled('p')`
  margin-bottom: 10px;
  margin-top: 10px;
`

function emptyKeyResult() {
  return { text: '' }
}

function emptyKeyResults() {
  return [emptyKeyResult(), emptyKeyResult(), emptyKeyResult(), emptyKeyResult()]
}

class AddObjective extends Component {
  state = {
    adding: false,
    importing: false,
    text: '',
    keyResults: emptyKeyResults()
  }

  addKeyResult = () => {
    this.setState({
      keyResults: this.state.keyResults.concat([emptyKeyResult()])
    })
  }

  removeKeyResult = (index) => {
    return () => {
      this.setState({
        keyResults: this.state.keyResults.filter((el, i) => i !== index)
      })
    }
  }

  cancel = () => {
    this.setState({
      adding: false,
      importing: false,
      text: '',
      keyResults: emptyKeyResults()
    })
  }

  keyResultTextChange = (krIndex) => {
    return (evt) => {
      const newKeyResults = _.cloneDeep(this.state.keyResults)
      newKeyResults[krIndex].text = evt.target.value
      this.setState({ keyResults: newKeyResults })
    }
  }

  import = () => {
    this.setState({ importing: true })
  }

  onImport = (evt) => {
    const text = evt.target.value
    const split = text.split('\n')

    const objective = split.shift()
    const keyResults = split.map((krText) => {
      const kr = emptyKeyResult()
      kr.text = krText
      return kr
    })

    this.setState({ importing: false, text: objective, keyResults })
  }

  textChange = (evt) => {
    this.setState({
      text: evt.target.value,
    })
  }

  submitForm = (evt) => {
    evt.preventDefault()
    const { okr } = this.props
    const { text, keyResults } = this.state

    const paramKeyResults = keyResults.map(({ text }) => ({ content: text }))
    const params = { okr_id: okr.id, content: text, key_results: paramKeyResults }

    Objective.create(params).then(() => {
      okr.objectiveCreated().then(() => {
        this.cancel()
      })
    })
  }

  wrappedContent(fn) {
    return (
      <Panel>
        <Panel.Heading>
          <Panel.Title>
            Add Objective
          </Panel.Title>
        </Panel.Heading>
        <Panel.Body>
          <p>
            Aren't sure about creating your objective?
            You can read more about OKR creation in the <a target="_blank" href="http://okrplaybook.salesloft.com/">SalesLoft OKR Playbook.</a>
          </p>
          {fn()}
        </Panel.Body>
      </Panel>
    )
  }

  render() {
    const { adding, keyResults, importing, text } = this.state

    if (!adding) {
      return (
        <div>
          <Add onClick={() => this.setState({ adding: true })}>+ Add Objective</Add>
        </div>
      )
    }

    if (importing) {
      return this.wrappedContent(() => (
        <div>
          <div>
            <textarea className="form-control" rows="6" onChange={this.onImport} placeholder="Copy one objective + its KRs here" />
          </div>
          <div className="mt-10">
            <FormButton type="button" bsClass="btn-xs" onClick={this.cancel}>Cancel</FormButton>
          </div>
        </div>
      ))
    }

    return this.wrappedContent(() => (
      <div>
        <form onSubmit={this.submitForm}>
          <div>
            <Input autoFocus placeholder="Objective" required value={text} onChange={this.textChange} />
          </div>

          <Para>as measured by...</Para>

          <KeyResultList>
            {
              keyResults.map(({ text }, index) => (
                <KeyResult key={index}>
                  <Input placeholder="a key result" required value={text} onChange={this.keyResultTextChange(index)} />
                  <FormButton type="button" bsClass="btn-xs" onClick={this.removeKeyResult(index)}>Remove</FormButton>
                </KeyResult>
              ))
            }
            <KeyResult>
              <FormButton type="button" bsClass="btn-xs" onClick={this.addKeyResult}>+ KR</FormButton>
            </KeyResult>
          </KeyResultList>

          <div>
            <FormButton type="submit" bsClass="btn-xs btn-primary">Add</FormButton>
            <FormButton type="button" bsClass="btn-xs" onClick={this.import}>Import from Sheets</FormButton>
            <FormButton type="button" bsClass="btn-xs" onClick={this.cancel}>Cancel</FormButton>
          </div>
        </form>
      </div>
    ))
  }
}

export default AddObjective
