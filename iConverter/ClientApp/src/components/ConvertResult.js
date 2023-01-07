import React from 'react'
import Spinner from './Spinner'


function ConvertResult({ Loading, amount, from, into, result, rate }) {
    return (
        <>
            {Loading ? (
                <Spinner />
            ) : (
                result &&
                rate && (
                    <>
                        <h1 className="result">{amount} {from} = {result} {into}</h1>
                        <h4 className="rate ">Exchange rate: {rate}</h4>
                    </>
                )
            )}
        </>
    )
}

export default ConvertResult