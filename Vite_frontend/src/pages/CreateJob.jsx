import { useEffect, useState } from 'react'
import { useNavigate } from 'react-router-dom'

import {
  createAdminJob,
  getJobMeta,
} from '../api/adminApi'

import styles from './CSS/CreateJob.module.css'

function CreateJob() {
  const navigate = useNavigate()

  const [categories, setCategories] = useState([])

  const [form, setForm] = useState({
    name: '',
    company: '',
    description: '',
    salary_min: '',
    salary_max: '',
    job_type: 'full_time',
    category_id: '',
    subcategory_id: '',
    no_of_openings: '1',
    work_location: '',
  })

  const [loadingMeta, setLoadingMeta] = useState(true)
  const [submitting, setSubmitting] = useState(false)

  const [error, setError] = useState('')
  const [success, setSuccess] = useState('')

  useEffect(() => {
    async function loadMeta() {
      try {
        const data = await getJobMeta()

        setCategories(data.categories || [])
      } catch (error) {
        setError(error.message)
      } finally {
        setLoadingMeta(false)
      }
    }

    loadMeta()
  }, [])

  const selectedCategory = categories.find(
    (category) =>
      String(category.id) === String(form.category_id)
  )

  function handleChange(event) {
    const { name, value } = event.target

    setForm((previous) => ({
      ...previous,
      [name]: value,
    }))

    setError('')
    setSuccess('')
  }

  function handleCategoryChange(event) {
    const categoryId = event.target.value

    setForm((previous) => ({
      ...previous,
      category_id: categoryId,
      subcategory_id: '',
    }))

    setError('')
  }

  async function handleSubmit(event) {
    event.preventDefault()

    setError('')
    setSuccess('')

    try {
      setSubmitting(true)

      const data = await createAdminJob(form)

      setSuccess(
        `Job "${data.job.name}" created successfully.`
      )

      setForm({
        name: '',
        company: '',
        description: '',
        salary_min: '',
        salary_max: '',
        job_type: 'full_time',
        category_id: '',
        subcategory_id: '',
        no_of_openings: '1',
        work_location: '',
      })
    } catch (error) {
      setError(error.message)
    } finally {
      setSubmitting(false)
    }
  }

  if (loadingMeta) {
    return (
      <div className={styles.page}>
        <div className={styles.message}>
          Loading job categories...
        </div>
      </div>
    )
  }

  return (
    <div className={styles.page}>

      <div className={styles.header}>
        <div>
          <h1>Create Job</h1>
          <p>
            Add a new job to the platform
          </p>
        </div>

        <button
          type="button"
          className={styles.backButton}
          onClick={() => navigate('/dashboard')}
        >
          Back
        </button>
      </div>

      <form
        className={styles.form}
        onSubmit={handleSubmit}
      >

        <section className={styles.section}>
          <h2>Job Information</h2>

          <div className={styles.grid}>

            <div className={styles.field}>
              <label>
                Job Name
              </label>

              <input
                name="name"
                value={form.name}
                onChange={handleChange}
                placeholder="e.g. Experienced Mason"
                required
              />
            </div>

            <div className={styles.field}>
              <label>
                Company
              </label>

              <input
                name="company"
                value={form.company}
                onChange={handleChange}
                placeholder="e.g. Himalayan Construction"
                required
              />
            </div>

            <div className={styles.field}>
              <label>
                Work Location
              </label>

              <input
                name="work_location"
                value={form.work_location}
                onChange={handleChange}
                placeholder="e.g. Srinagar, Jammu & Kashmir"
                required
              />
            </div>

            <div className={styles.field}>
              <label>
                Job Type
              </label>

              <select
                name="job_type"
                value={form.job_type}
                onChange={handleChange}
              >
                <option value="full_time">
                  Full Time
                </option>

                <option value="part_time">
                  Part Time
                </option>

                <option value="contract">
                  Contract
                </option>
              </select>
            </div>

          </div>

          <div className={styles.field}>
            <label>
              Description
            </label>

            <textarea
              name="description"
              value={form.description}
              onChange={handleChange}
              placeholder="Describe the job..."
              rows="6"
              required
            />
          </div>
        </section>


        <section className={styles.section}>
          <h2>Job Classification</h2>

          <div className={styles.grid}>

            <div className={styles.field}>
              <label>
                Category
              </label>

              <select
                value={form.category_id}
                onChange={handleCategoryChange}
                required
              >
                <option value="">
                  Select category
                </option>

                {categories.map((category) => (
                  <option
                    key={category.id}
                    value={category.id}
                  >
                    {category.name}
                  </option>
                ))}
              </select>
            </div>


            <div className={styles.field}>
              <label>
                Subcategory
              </label>

              <select
                name="subcategory_id"
                value={form.subcategory_id}
                onChange={handleChange}
                disabled={!selectedCategory}
                required
              >
                <option value="">
                  Select subcategory
                </option>

                {selectedCategory?.subcategories.map(
                  (subcategory) => (
                    <option
                      key={subcategory.id}
                      value={subcategory.id}
                    >
                      {subcategory.name}
                    </option>
                  )
                )}
              </select>
            </div>

          </div>
        </section>


        <section className={styles.section}>
          <h2>Salary & Openings</h2>

          <div className={styles.grid}>

            <div className={styles.field}>
              <label>
                Minimum Salary
              </label>

              <input
                type="number"
                name="salary_min"
                value={form.salary_min}
                onChange={handleChange}
                placeholder="25000"
                min="0"
              />
            </div>

            <div className={styles.field}>
              <label>
                Maximum Salary
              </label>

              <input
                type="number"
                name="salary_max"
                value={form.salary_max}
                onChange={handleChange}
                placeholder="35000"
                min="0"
              />
            </div>

            <div className={styles.field}>
              <label>
                Number of Openings
              </label>

              <input
                type="number"
                name="no_of_openings"
                value={form.no_of_openings}
                onChange={handleChange}
                min="1"
                required
              />
            </div>

          </div>
        </section>


        {error && (
          <div className={styles.error}>
            {error}
          </div>
        )}

        {success && (
          <div className={styles.success}>
            {success}
          </div>
        )}


        <button
          type="submit"
          className={styles.submitButton}
          disabled={submitting}
        >
          {submitting
            ? 'Creating Job...'
            : 'Create Job'}
        </button>

      </form>
    </div>
  )
}

export default CreateJob