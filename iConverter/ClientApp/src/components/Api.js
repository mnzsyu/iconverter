export const heading = "currency converter"
export const API_DOMAIN = "https://api.freecurrencyapi.com/v1/latest?apikey="
export const API_KEY = "7uIjiE1RxCoUyA5TyiQjJr3ktu0cnHcd7xQ5IoQU"
export const endpointPath = (from, to) =>
    `${API_DOMAIN}${API_KEY}&base_currency=${from}&currencies=${to}`;
