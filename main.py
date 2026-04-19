class BackupSystem:
    def __init__(self):
        self.backups = []

    def create_backup(self, file_name, file_content):
        self.backups.append({"file_name": file_name, "file_content": file_content})

    def restore_backup(self, file_name):
        for backup in self.backups:
            if backup["file_name"] == file_name:
                return backup["file_content"]
        return None

    def delete_backup(self, file_name):
        for backup in self.backups:
            if backup["file_name"] == file_name:
                self.backups.remove(backup)
                return True
        return False

    def list_backups(self):
        return [backup["file_name"] for backup in self.backups]

class File:
    def __init__(self, name, content):
        self.name = name
        self.content = content

class FileManager:
    def __init__(self):
        self.files = []
        self.backup_system = BackupSystem()

    def create_file(self, name, content):
        self.files.append(File(name, content))

    def backup_file(self, file_name):
        for file in self.files:
            if file.name == file_name:
                self.backup_system.create_backup(file_name, file.content)
                return True
        return False

    def restore_file(self, file_name):
        file_content = self.backup_system.restore_backup(file_name)
        if file_content is not None:
            for file in self.files:
                if file.name == file_name:
                    file.content = file_content
                    return True
        return False

    def delete_file(self, file_name):
        for file in self.files:
            if file.name == file_name:
                self.files.remove(file)
                return True
        return False

def main():
    file_manager = FileManager()
    file_manager.create_file("file1.txt", "Hello World!")
    file_manager.create_file("file2.txt", "This is a test file.")
    file_manager.backup_file("file1.txt")
    file_manager.backup_file("file2.txt")
    file_manager.delete_file("file1.txt")
    file_manager.restore_file("file1.txt")
    for file in file_manager.files:
        print(f"File Name: {file.name}, File Content: {file.content}")

if __name__ == "__main__":
    main()