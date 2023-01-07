using Xunit.Abstractions;

namespace iConverter_test
{
    public class TestVariableTypes
    {
        private readonly ITestOutputHelper _testOutputHelper;
        public TestVariableTypes(ITestOutputHelper testOutputHelper)
        {
            _testOutputHelper = testOutputHelper;
        }

        [Fact]
        public void WeatherForecastHasCorrectTypes()
        {
            var weatherForecast = new iConverter.WeatherForecast();

            var weatherDate = weatherForecast.Date;
            var weatherTemperatureC = weatherForecast.TemperatureC;
            var weatherTemperatureF = weatherForecast.TemperatureF;

            Assert.IsType<DateTime>(weatherDate);
            Assert.IsType<int>(weatherTemperatureC);
            Assert.IsType<int>(weatherTemperatureF);

            _testOutputHelper.WriteLine($"Got date: {weatherDate.ToString()}");
            _testOutputHelper.WriteLine($"Got temperature C: {weatherTemperatureC.ToString()}");
            _testOutputHelper.WriteLine($"Got temperature F: {weatherTemperatureF.ToString()}");
        }
    }
}