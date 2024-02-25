# Import the required module
Import-Module Az.Sql

# Define the function to execute the SQL command
function Add-UserToAuthorization {
    param (
        [string]$ConnectionString,
        [string]$User
    )
    # Connect to the Azure SQL database

    $sqlQuery = @"
    DECLARE @Email VARCHAR(MAX);
    SET @Email = ${User};
    INSERT INTO [Auth].[Subjects] (Sub, Name, ImageUrl, Email) values (@Email,@Email, null, null);

    DECLARE @SupRole INT;
    DECLARE @CoreRole INT;
    -- 13: Supervisor Admin role, 1:Admin Core
    SET @SupRole = 13; 
    SET @CoreRole = 1;

    DECLARE @MeSubjectId INT;
    SET @MeSubjectId = (SELECT Id FROM [Auth].[Subjects] WHERE Sub = @Email);
    INSERT INTO [Auth].[RoleSubjects] (RoleId, SubjectId) values (@SupRole,@MeSubjectId);
    INSERT INTO [Auth].[RoleSubjects] (RoleId, SubjectId) values (@CoreRole,@MeSubjectId);
"@

    # Execute the SQL query
    Invoke-SqlCmd -ConnectionString $connectionString -Query $SqlQuery
}
