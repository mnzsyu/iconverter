#### Взять для задания стандартный sample приложения на ASP.NET Core (.NET 6), и загрузить его в гитхаб  
Условия:
* Код приложения должен быть размещен на гитхаб  
* Можно использовать только сервисы AWS  
* Приложение должно быть упаковано в докер контейнер  
* Для хостинга приложения разрешено использовать только ECS  
* По пушу в master/main ветку репозитория должно быть организовано автоматическое юнит-тестирование и доставка приложения на dev  
* После ручной проверки, эта же версия приложения должна доставляться на prod  

***

Так как я пропустил три задания в Section 1, в том числе написание скрипта для конвертирования валют, я решил создать своё приложение, вместо использования стандартного сэмпла  
#### Приложение:  
- ASP.NET core 6.0 - backend
    - Web application
    - SPA proxy
    - Weather forecast controller
- React - frontend
    - Fetch data from weather forecast controller (стандартное демо в webapp .NET проекте)
    - Counter (стандартное демо в webapp .NET проекте)
    - Currency Converter - получает курс конвертации через freecurrencyapi

Приложение состоит из двух проектов (.NET with React и xUnit test) в одном sln-файле  

![Screenshot](./Screenshots/Screenshot1.png)  
![Screenshot](./Screenshots/Screenshot2.png)  
![Screenshot](./Screenshots/Screenshot3.png)  
![Screenshot](./Screenshots/Screenshot4.png)  

#### CI/CD:  
В качестве CI/CD инструмента был выбран Github Actions  
[Workflow](./.github/workflows/main.yml)  

#### Юнит-тесты:  
- NPM: [App.test.js](./iConverter/ClientApp/src/App.test.js) - стандартный тест, проверяющий корректность отрисовки рендеров
- .NET: [iConverter_test.cs](./iConverter-test/iConverter_test.cs) - тест, проверяющий корректность данных, отдаваемых контроллером WeatherForecastController

#### Сборка docker-образа:  
[Dockerfile](./Dockerfile)  
Образ приложения собирается на базе образов 'mcr.microsoft.com/dotnet/sdk:6.0', 'mcr.microsoft.com/dotnet/aspnet:6.0', 'node:19-alpine3.16'. Multi-stage сборка позволяет получить готовый образ с приложением весом менее 90МБ  

#### AWS:  
Создание инфраструктуры в AWS реализовано через Terraform, но разделено на несколько шагов:  
* [Terraform step-1](./Terraform/step-1/) - создание репозитория в ECR   
* Push начального образа в ECR  
    * Для создания task definition в ECR необходимо иметь в репозитории начальный образ. Этот образ будет использоваться только при создании инфраструктуры. Чтобы сохранить начальный образ в репозитории, необходимо:  
    * Задать значения в bash для переменных:  
    ```
    ACCOUNT='824569003070' \
    REGION='eu-west-3' \
    REPO='iconverter'
    ```
    * Собрать образ приложения локально (хотя можно использовать абсолютно любой образ):  
    ```
    docker build -t ${ACCOUNT}.dkr.ecr.${REGION}.amazonaws.com/${REPO}:initial .
    ```
    * Авторизовать docker в aws:  
    ```
    aws ecr get-login-password \
        --region ${REGION} \
    | docker login \
        --username AWS \
        --password-stdin ${ACCOUNT}.dkr.ecr.${REGION}.amazonaws.com
    ```
    * Сохранить образ в репозиторий:  
    docker push ${ACCOUNT}.dkr.ecr.${REGION}.amazonaws.com/${REPO}:initial
* [Terraform step-2](./Terraform/step-2/) - создание компонентов инфраструктуры (VPC, сети и их компоненты, security-группы, балансировщики, кластеры, контейнеры). Тестовая и промышленная инфраструктуры разнесены по разным VPC
