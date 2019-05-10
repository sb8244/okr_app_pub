import React, { Component } from 'react'
import styled from 'styled-components'
import moment from 'moment'
import {
  Button,
  ControlLabel,
  FormControl,
  FormGroup,
  HelpBlock,
} from 'react-bootstrap'

import { Cycle, Okr } from '@utils/api'

const FormButton = styled(Button)`
  margin-right: 10px;
`

export default class AddOkrForm extends Component {
  state = {
    futureCycles: [],
    loaded: false,
    selectedCycleId: '',
  }

  componentDidMount() {
    Cycle.allFuture().then(futureCycles => {
      let selectedCycleId = ''
      if (futureCycles.length) {
        selectedCycleId = futureCycles[0].id
      }

      this.setState({ futureCycles, loaded: true, selectedCycleId })
    })
  }

  computeAvailableCycles() {
    const { activeCycles } = this.props
    const { futureCycles } = this.state
    const activeCycleIds = activeCycles.map(({ id }) => id)

    return futureCycles.filter(({ id }) => !activeCycleIds.includes(id))
  }

  createOkr = evt => {
    evt.preventDefault()
    const { selectedCycleId } = this.state
    const params = {
      cycle_id: selectedCycleId,
      ...this.props.ownerParams,
    }

    Okr.create(params).then(() => {
      this.props.afterCreate()
    })
  }

  cycleSelected = evt => {
    this.setState({
      selectedCycleId: evt.target.value,
    })
  }

  render() {
    const { loaded, selectedCycleId } = this.state

    if (!loaded) {
      return null
    }

    const selectedCycleValidation = selectedCycleId ? 'success' : 'error'
    const availableCycles = this.computeAvailableCycles()

    return (
      <form onSubmit={this.createOkr}>
        <FormGroup validationState={selectedCycleValidation}>
          <ControlLabel>Select a Cycle</ControlLabel>
          <FormControl
            componentClass="select"
            value={selectedCycleId}
            onChange={this.cycleSelected}
            required
          >
            <option />
            {availableCycles.map(({ id, title, starts_at, ends_at }) => (
              <option key={id} value={id}>
                {moment(starts_at).format('ll')} -{' '}
                {moment(ends_at).format('ll')}: {title}
              </option>
            ))}
          </FormControl>
          {getSelectCycleHelpBlock(selectedCycleId, availableCycles)}
        </FormGroup>

        <FormButton type="submit" bsClass="btn-sm btn-primary">Create OKR</FormButton>
      </form>
    )
  }
}

function getSelectCycleHelpBlock(selectedCycleId, availableCycles) {
  if (availableCycles.length === 0) {
    return (
      <HelpBlock>
        No future cycles to create an OKR for. Is your OKR below?
      </HelpBlock>
    )
  }

  return null
}
