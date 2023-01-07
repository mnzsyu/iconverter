import React, { Component } from "react";
import './Converter.css';
import {
    endpointPath
} from './Api';
import Dropdowns from "./Dropdowns"
import ConvertResult from "./ConvertResult"

export class CurrencyConverter extends Component {

    constructor(props) {
        super(props);
        this.default = {
            from: 'USD',
            into: 'GBP',
            loading: false,
            amount: 1,
            conversionResult: '',
            conversionRate: '',
            savedFrom: 'USD',
            savedInto: 'GBP',
            savedAmount: 1,
            savedConversionResult: '',
            savedConversionRate: ''
        }
        this.state = this.default
    }

    convertCurrency = async ({ from, into, amount }) => {
        this.setState({ loading: true });
        let url = endpointPath(from, into);
        let data = await fetch(url);
        let parsedData = await data.json();
        const conversionRate = parsedData.data[into];
        console.log(parsedData)

        const conversionResult = conversionRate * amount;
        this.setState({
            savedConversionRate: conversionRate,
            savedConversionResult: conversionResult,
            savedFrom: from,
            savedInto: into,
            savedAmount: amount,
            loading: false
        })
    }

    handleInput = (event) => {
        this.setState({ amount: event.target.value });
    }

    handleFrom = (event) => {
        this.setState({ from: event.currentTarget.value });
    }

    handleInto = (event) => {
        this.setState({ into: event.currentTarget.value });
    }

    handleReset = () => {
        this.setState(this.default)
    }

    handleSwitch = () => {
        const { from, into } = this.state;
        this.setState({ from: into, into: from });
    };

    render() {
        const {
            from,
            into,
            amount,
            loading,
            savedAmount,
            savedConversionRate,
            savedConversionResult,
            savedFrom,
            savedInto
        } = this.state
        return (
            <>
                <div className='container-fluid shadow main'>
                    <div className='row panel'>

                        <label className='panellabel'>Amount</label>
                        <div className='paneldiv'>
                            <input
                                className="amount bg-dark text-white border-dark shadow panelelement"
                                placeholder="Enter Amount"
                                value={amount}
                                type="number"
                                onChange={this.handleInput}
                            />
                        </div>

                        <label className='panellabel'>From</label>
                        <div className='paneldiv'>
                            <Dropdowns
                                className='panelelement'
                                handleChange={this.handleFrom}
                                value={from}
                            ></Dropdowns>
                        </div>

                        <label className='panellabel'></label>
                        <div className='paneldiv'>
                            <button
                                className="btn btn-primary shadow text-center"
                                onClick={this.handleSwitch}
                            >{"<>"}  <i className="fas fa-sort align-middle"></i></button>
                        </div>

                        <label className='panellabel'>To</label>
                        <div className='paneldiv'>
                            <Dropdowns
                                handleChange={this.handleInto}
                                value={into}
                            ></Dropdowns>
                        </div>

                        <div className='paneldiv d-flex justify-content-center'>
                            <button
                                className='btn btn-secondary btn-lg shadow'
                                text="Reset"
                                onClick={this.handleReset}
                            >x <i className="fas fa-redo-alt align-middle"></i></button>
                        </div>

                        <div className='paneldiv'>
                            <button
                                className='btn btn-success btn-lg shadow'
                                disabled={amount === "0" || amount === "" || amount < 0}
                                onClick={() => this.convertCurrency(this.state)}
                            >= <i className="align-middle"></i></button>
                        </div>

                    </div>

                    <div className='mt-5 mb-2 text-center'>
                        <ConvertResult
                            Loading={loading}
                            amount={savedAmount}
                            from={savedFrom}
                            into={savedInto}
                            result={savedConversionResult}
                            rate={savedConversionRate}
                        ></ConvertResult>
                    </div>

                </div>
            </>
        )
    }
}

